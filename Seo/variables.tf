/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

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
variable "seo_domain" {
  type = "string"
  description = "The fully qualified seo domain name."
}
variable "seo_resources_domain" {
  type = "string"
  description = "The fully qualified seo resources domain name."
}
variable "seo_resources_domain_certificate_arn" {
  type = "string"
  description = "The ARN of the ACM certificate to be used for the seo resources website distribution."
}
