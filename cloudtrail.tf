resource "aws_cloudtrail" "application_development_bucket_logging_cloudtrail" {
  name           = "application_development_bucket_logging_cloudtrail"
  s3_bucket_name = "${aws_s3_bucket.cloudtrail_s3_bucket.id}"
  s3_key_prefix  = ""

  enable_logging                = true
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = false

    # https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DataResource.html
    data_resource {
      type = "AWS::S3::Object"

      values = [
        "arn:aws:s3:::${aws_s3_bucket.application_development_s3_bucket.id}/",
      ]
    }
  }

  tags {
    Name        = "application development bucket logging cloudtrail"
    Environment = "${var.environment}"
  }

  # https://github.com/hashicorp/terraform/issues/6388
  depends_on = [
    "aws_s3_bucket_policy.cloudtrail_s3_bucket_policy",
  ]
}
