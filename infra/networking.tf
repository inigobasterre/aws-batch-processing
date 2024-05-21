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

resource "aws_nat_gateway" "example" {
  subnet_id     = aws_subnet.private_subnet.id

  tags = merge({
    Name = "inigo-basterretxea-nat-gateway"
  }, var.tags)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "example" {
  vpc_id = aws_vpc.main.id
  description = "Security group to allow outbound from the VPC"
  depends_on = [aws_vpc.main]

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = merge({
    Name = "inigo-basterretxea-vpc-sg"
  }, var.tags)
}