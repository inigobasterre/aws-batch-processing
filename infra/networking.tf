resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

    tags = merge({
    Name = "inigo-basterretxea-internet-gateway"
  }, var.tags)
}

resource "aws_eip" "nat_ip" {
  domain                    = "vpc"
  tags = merge({
    Name = "inigo-basterretxea-nat-eip"
  }, var.tags)
}

resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.nat_ip.id

  tags = merge({
    Name = "inigo-basterretxea-nat-gateway"
  }, var.tags)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# resource "aws_network_acl" "egress_only_acl" {
#   vpc_id = aws_vpc.main.id
#   subnet_ids = [aws_subnet.public_subnet.id]

#   egress {
#     protocol   = -1
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
#   ingress {
#     protocol   = -1
#     rule_no    = 100
#     action     = "deny"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   tags = merge({
#     Name = "inigo-basterretxea-vpc-acl"
#   }, var.tags)
# }

resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.main.id
  description = "Security group to allow outbound from the VPC"
  depends_on = [aws_vpc.main]

  egress {
    from_port   = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({
    Name = "inigo-basterretxea-vpc-sg"
  }, var.tags)
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = merge({
    Name = "inigo-basterretxea-vpc-private-rt"
  }, var.tags)
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_route" "egress_route" {
  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}