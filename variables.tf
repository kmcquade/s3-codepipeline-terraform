variable "aws_region" {
  type = "string"
}

variable "application" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "application_development_s3_bucket_name" {
  type = "string"
}

variable "cloudtrail_s3_bucket_name" {
  type = "string"
}

variable "codepipeline_artifactstore_s3_bucket_name" {
  type = "string"
}

variable "codepipeline_source_stage_s3_object_key" {
  type = "string"
}

variable "codebuild_compute_type" {
  type    = "string"
  default = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_image" {
  type    = "string"
  default = "aws/codebuild/ubuntu-base:14.04"
}
