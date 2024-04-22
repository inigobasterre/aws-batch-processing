resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = merge({
    Name = "inigo-basterretxea-vpc"
  }, var.tags)
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  tags = merge({
    Name = "inigo-basterretxea-lambda-subnet"
  }, var.tags)
}