provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
resource "aws_route53_delegation_set" "main" {
  reference_name = "${var.environment}"
}
