# CloudTrail and CodePipeline

resource "aws_cloudwatch_event_rule" "cloudtrail_codepipeline_cloudwatch_event_rule" {
  name = "${var.application}_${var.environment}_cloudtrail-codepipeline"

  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html#CloudWatchEventsPatterns
  # https://docs.aws.amazon.com/codepipeline/latest/userguide/create-cloudtrail-S3-source-cfn.html
  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject"
    ],
    "requestParameters": {
      "bucketName": [
        "${aws_s3_bucket.application_development_s3_bucket.id}"
      ]
    }
  }
}
PATTERN

  description = "CloudWatch Event rule that starts CodePipeline execution in ${var.environment}"
  is_enabled  = "true"
}

resource "aws_cloudwatch_event_target" "cloudtrail_codepipeline_cloudwatch_event_target" {
  rule     = "${aws_cloudwatch_event_rule.cloudtrail_codepipeline_cloudwatch_event_rule.name}"
  arn      = "${aws_codepipeline.codepipeline.arn}"
  role_arn = "${aws_iam_role.cloudtrail_codepipeline_cloudwatch_event_target_iam_role.arn}"
}

# CloudWatch Event Target IAM Role
# https://docs.aws.amazon.com/codepipeline/latest/userguide/create-cloudtrail-S3-source-cli.html

data "aws_iam_policy_document" "cloudtrail_codepipeline_event_target_iam_policy_document" {
  statement {
    sid    = "StartPipelineExecution"
    effect = "Allow"

    actions = [
      "codepipeline:StartPipelineExecution",
    ]

    resources = [
      "${aws_codepipeline.codepipeline.arn}",
    ]
  }
}

resource "aws_iam_policy" "cloudtrail_codepipeline_cloudwatch_event_target_iam_policy" {
  name        = "${var.application}_${var.environment}_cloudtrail_codepipeline_cloudwatch_event_rule"
  path        = "/"
  description = "iam policy for CloudWatch Event target that starts CodePipeline execution in ${var.environment}"

  policy = "${data.aws_iam_policy_document.cloudtrail_codepipeline_event_target_iam_policy_document.json}"
}

data "aws_iam_policy_document" "cloudtrail_codepipeline_cloudwatch_event_target_assume_role_iam_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "cloudtrail_codepipeline_cloudwatch_event_target_iam_role" {
  name               = "${var.application}_${var.environment}_cloudwatch_event_rule"
  assume_role_policy = "${data.aws_iam_policy_document.cloudtrail_codepipeline_cloudwatch_event_target_assume_role_iam_policy_document.json}"
  description        = "iam role for CloudWatch Event target that starts CodePipeline execution in ${var.environment}"
}

resource "aws_iam_role_policy_attachment" "cloudtrail_codepipeline_cloudwatch_event_target_iam_role_policy_attachment" {
  role       = "${aws_iam_role.cloudtrail_codepipeline_cloudwatch_event_target_iam_role.name}"
  policy_arn = "${aws_iam_policy.cloudtrail_codepipeline_cloudwatch_event_target_iam_policy.arn}"
}
