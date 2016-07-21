variable "aws_region" {
  type = "string"
  description = "The AWS region."
  default = "us-east-1"
}

variable "aws_access_key" {
  type = "string"
  description = "The AWS access key."
}

variable "aws_secret_key" {
  type = "string"
  description = "The AWS secret key"
}

variable "environment" {
  type = "string"
  description = "The environment/account name."
}

variable "platform_domain" {
  type = "string"
  description = "The fully qualified platform domain name."
}
