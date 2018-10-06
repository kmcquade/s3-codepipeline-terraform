resource "aws_s3_bucket" "application_development_s3_bucket" {
  bucket = "${var.application_development_s3_bucket_name}"
  acl    = "private"

  tags {
    Name        = "application development s3 bucket"
    Environment = "${var.environment}"
  }

  force_destroy = true

  versioning {
    enabled = true
  }
}
