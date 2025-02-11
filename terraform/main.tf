terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "af-south-1"
}


resource "aws_db_instance" "beantradedb" {
  identifier             = "beantradedb"
  engine                 = "sqlserver-ex"
  engine_version         = "15.00.4415.2.v1"
  instance_class         = "db.t2.micro"
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