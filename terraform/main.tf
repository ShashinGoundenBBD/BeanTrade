terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
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

resource "aws_db_instance" "beantradedb" {
  identifier             = "beantradedb"
  engine                 = "sqlserver-ex"
  engine_version         = "15.00.4415.2.v1"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = true
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  tags = {
    Name = "beantradedb"
  }
}

output "db_host" {
  value = aws_db_instance.beantradedb.endpoint
  description = "The endpoint of the SQL Server RDS instance"
}

output "db_name" {
  value = aws_db_instance.beantradedb.tags.Name
  description = "The database name"
}