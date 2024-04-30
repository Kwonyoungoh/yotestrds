resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "s3testdb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = var.rds_username
  password             = var.rds_secret
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]

  publicly_accessible = true 
  skip_final_snapshot  = true
}

data "aws_vpc" "default" {
  tags = {
    Name = "main"
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  tags = {
    public = "on"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "my-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "default" {
  name        = "rds-public-access"
  description = "Allow all inbound traffic for RDS"
  vpc_id      = data.aws_vpc.default.id 

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}