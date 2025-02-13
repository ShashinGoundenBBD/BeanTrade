terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region =  "af-south-1"
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default_vpc"
  }
}

data "aws_availability_zones" "available_zones" {
  
}

resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

resource "aws_security_group" "allow_mssql" {
  name_prefix = "allow_mssql_"

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "beantradedb7" {
  identifier             = "beantradedb7"
  engine                 = "sqlserver-ex"
  engine_version         = "15.00.4415.2.v1"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = true
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_mssql.id]
  tags = {
    Name = "beantradedb7"
  }

  provisioner "local-exec" {
    command = <<-EOT
      sqlcmd -S ${self.endpoint} -U ${self.username} -P '${self.password}' -Q "CREATE DATABASE BeanTrade;";
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

output "db_host" {
  value = aws_db_instance.beantradedb7.endpoint
  description = "The endpoint of the SQL Server RDS instance"
}

output "db_name" {
  value = aws_db_instance.beantradedb7.db_name
  description = "The database name"
}