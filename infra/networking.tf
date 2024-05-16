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
    Name = "inigo-basterretxea-private-subnet"
  }, var.tags)
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  tags = merge({
    Name = "inigo-basterretxea-public-subnet"
  }, var.tags)
}

resource "aws_security_group" "example" {
  vpc_id = aws_vpc.main.id

  egress  = []
}