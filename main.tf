# Terraform AWS Example — Intentionally Insecure for Testing Terrascan

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Example: Public S3 bucket (security misconfiguration)
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "terrascan-insecure-bucket-${random_id.bucket_id.hex}"
  acl    = "public-read"  # <-- Terrascan should flag this
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

# Example: Security group with open SSH port (another misconfiguration)
resource "aws_security_group" "insecure_sg" {
  name        = "insecure-sg"
  description = "Allows all inbound traffic"
  vpc_id      = "vpc-12345678"

  ingress {
    description = "Allow all inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # <-- Terrascan will flag this
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "insecure-sg"
  }
}

# Example: EC2 instance using a plain-text key name (for testing)
resource "aws_instance" "insecure_instance" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  key_name               = "my-plaintext-key"  # <-- Should be managed securely
  associate_public_ip_address = true

  tags = {
    Name = "InsecureInstance"
  }
}
