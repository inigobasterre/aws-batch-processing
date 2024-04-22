resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = "inigo-basterretxea-tf-state-bucket"
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "tf-state-bucket-versioning" {
  bucket  = aws_s3_bucket.tf-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "inigo-basterretxea-tf-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  tags = var.tags
 
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "inigo-basterretxea-tf-state-bucket"
    key    = "terraform.tfstate"
    dynamodb_table = "inigo-basterretxea-tf-state-lock-dynamo"
  }
}