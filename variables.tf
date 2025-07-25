variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-042b4708b1d05f512"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "uptime_kuma"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH"
  type        = string
  default     = "109.87.215.217/32"
}

variable "allowed_kuma_cidr" {
  description = "CIDR block allowed to access Uptime Kuma"
  type        = string
  default     = "109.87.215.217/32"
}

variable "aws_key_name" {
  description = "EC2 SSH Key Name"
  type        = string
  default     = "Stockholm"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
}
