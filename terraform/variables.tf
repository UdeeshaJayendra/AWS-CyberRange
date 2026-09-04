variable "aws_region" {
  description = "AWS region for the CyberRange"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-cyberrange"
}

variable "vpc_cidr" {
  description = "CIDR block for the CyberRange VPC"
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public lab subnet"
  type        = string
  default     = "10.50.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "ap-south-1a"
}
variable "instance_type" {
  description = "EC2 instance type for the CyberRange target"
  type        = string
  default     = "t3.micro"
}
variable "admin_cidr" {
  description = "Public IP address allowed to access SSH, in CIDR notation"
  type        = string
}