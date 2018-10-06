resource "aws_cloudwatch_log_group" "codebuild_cloudwatch_log_group" {
  name = "/aws/codebuild/${aws_codebuild_project.codebuild_project.name}"

  tags {
    Name        = "/aws/codebuild/${aws_codebuild_project.codebuild_project.name}"
    Application = "${var.application}"
    Environment = "${var.environment}"
  }
}
