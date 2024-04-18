terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = "inigo-basterretxea-tf-state-bucket"

  tags = {
    _project = "inigo-basterretxea-batch-processing"
    _purpose = "testing"
    _business_criticality = "low"
    _end_date = "150624"
    _owner_email = "inigo.basterretxea@mesh-ai.com"
  }
}