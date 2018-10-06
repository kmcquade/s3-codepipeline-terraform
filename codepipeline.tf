locals {
  source_stage_output_artifacts = [
    "App",
  ]

  build_stage_output_artifacts = [
    "Build",
  ]
}

resource "aws_codepipeline" "codepipeline" {
  name = "${var.application}_${var.environment}_codepipeline"

  # https://docs.aws.amazon.com/codepipeline/latest/userguide/how-to-custom-role.html
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_artifactstore_s3_bucket.bucket}"
    type     = "S3"
  }

  # https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  stage {
    name = "Source"

    action {
      # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions-actiontypeid.html
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      name = "SourceFromS3"

      configuration {
        S3Bucket             = "${aws_s3_bucket.application_development_s3_bucket.bucket}"
        S3ObjectKey          = "${var.codepipeline_source_stage_s3_object_key}"
        PollForSourceChanges = "false"
      }

      output_artifacts = "${local.source_stage_output_artifacts}"
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      name = "${var.application}_${var.environment}_Build"

      configuration {
        ProjectName = "${aws_codebuild_project.codebuild_project.name}"
      }

      input_artifacts = "${local.source_stage_output_artifacts}"

      output_artifacts = "${local.build_stage_output_artifacts}"
    }
  }
}

# IAM Role
## https://docs.aws.amazon.com/codepipeline/latest/userguide/how-to-custom-role.html

data "aws_iam_policy_document" "codepipeline_policy_document" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]

    resources = [
      "${aws_s3_bucket.application_development_s3_bucket.arn}",
      "${aws_s3_bucket.application_development_s3_bucket.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.codepipeline_artifactstore_s3_bucket.arn}/*",
    ]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [
      "arn:aws:codebuild:${var.aws_region}:${local.aws_account_id}:project/${aws_codebuild_project.codebuild_project.name}",
    ]
  }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name = "${var.application}_${var.environment}_codepipeline"

  policy = "${data.aws_iam_policy_document.codepipeline_policy_document.json}"
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "codepipeline.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.application}_${var.environment}_codepipeline"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume_role_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_policy_attachment" {
  role       = "${aws_iam_role.codepipeline_role.name}"
  policy_arn = "${aws_iam_policy.codepipeline_policy.arn}"
}
