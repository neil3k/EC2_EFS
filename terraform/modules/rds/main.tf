resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.db_subnet

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "talend-db" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [var.security_group]
}

