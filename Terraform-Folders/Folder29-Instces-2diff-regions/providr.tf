# This file defines the AWS providers for the Terraform configuration to create EC2 instances in two different regions.

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}