variable "db_username" {
  type = string
  sensitive = true
}
variable "db_password" {
  type = string
  sensitive = true
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-private-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnet: subnet.id]

  tags = var.tags
}

resource "aws_db_instance" "my_sql_db" {
  allocated_storage    = 10
  db_name              = "inigo_basterretxea_rds"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  multi_az = false
  username = var.db_username
  password = var.db_password
  tags = var.tags

}