terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: store state in S3 for team collaboration
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "flask-app/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

# ──────────────────────────────────────
# Security Group
# ──────────────────────────────────────
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow HTTP, HTTPS, and SSH for Flask app"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "flask-app-sg"
    ManagedBy = "terraform"
  }
}

# ──────────────────────────────────────
# EC2 Instance
# ──────────────────────────────────────
resource "aws_instance" "flask_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # Bootstrap: install Python so Ansible can run
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3 python3-pip
  EOF

  tags = {
    Name        = "flask-app-server"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# ──────────────────────────────────────
# Elastic IP (stable public address)
# ──────────────────────────────────────
resource "aws_eip" "flask_eip" {
  instance = aws_instance.flask_app.id
  domain   = "vpc"

  depends_on = [aws_instance.flask_app]

  tags = {
    Name      = "flask-app-eip"
    ManagedBy = "terraform"
  }
}
