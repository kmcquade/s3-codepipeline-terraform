resource "aws_codebuild_project" "codebuild_project" {
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "${var.codebuild_compute_type}"

    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image = "${var.codebuild_image}"
    type  = "LINUX_CONTAINER"
  }

  name = "${var.application}_${var.environment}_codebuild_project"

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  build_timeout = "5"

  description = "codebuild project for ${var.application}"

  service_role = "${aws_iam_role.codebuild_iam_role.arn}"

  tags {
    Application = "${var.application}"
    Environment = "${var.environment}"
  }
}

# IAM Role

data "aws_iam_policy_document" "codebuild_iam_policy_document" {
  statement {
    sid = "CloudWatchLogsPolicy"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      // TODO restrict resources
      "*",
    ]
  }

  statement {
    sid = "S3GetObjectPolicy"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    resources = [
      "${aws_s3_bucket.codepipeline_artifactstore_s3_bucket.arn}/*",
    ]
  }

  statement {
    sid = "S3PutObjectPolicy"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.codepipeline_artifactstore_s3_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "codebuild_iam_policy" {
  name   = "${var.application}_${var.environment}_codebuild"
  policy = "${data.aws_iam_policy_document.codebuild_iam_policy_document.json}"
}

data "aws_iam_policy_document" "codebuild_assume_role_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "codebuild_iam_role" {
  name = "${var.application}_${var.environment}_codebuild"

  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume_role_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "codebuild_role_policy_attachment" {
  role       = "${aws_iam_role.codebuild_iam_role.name}"
  policy_arn = "${aws_iam_policy.codebuild_iam_policy.arn}"
}
