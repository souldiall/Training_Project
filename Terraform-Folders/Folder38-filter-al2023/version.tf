terraform {
  # "Specifies the required Terraform version and AWS provider for this configuration."
  required_version = "~>1.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}