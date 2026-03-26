terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  endpoints {
    s3             = "http://127.0.0.1:14566"
    ec2            = "http://127.0.0.1:14566"
    iam            = "http://127.0.0.1:14566"
    lambda         = "http://127.0.0.1:14566"
    dynamodb       = "http://127.0.0.1:14566"
    sqs            = "http://127.0.0.1:14566"
    sns            = "http://127.0.0.1:14566"
    cloudformation = "http://127.0.0.1:14566"
    ssm            = "http://127.0.0.1:14566"
    secretsmanager = "http://127.0.0.1:14566"
  }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
}
