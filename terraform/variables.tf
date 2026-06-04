variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID (region-specific)"
  type        = string
  # Ubuntu 22.04 LTS in us-east-1 — update for your region:
  # ap-south-1 (Mumbai):    ami-0f58b397bc5c1f2e8
  # us-east-1:              ami-0c7217cdde317cfec
  # eu-west-1:              ami-0905a3c97561e0b69
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro is free-tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair (must already exist in your AWS account)"
  type        = string
  # Override via: terraform apply -var="key_pair_name=my-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (restrict to your IP for security)"
  type        = string
  default     = "0.0.0.0/0"  # ⚠️ Change to your IP: e.g. "203.0.113.5/32"
}
