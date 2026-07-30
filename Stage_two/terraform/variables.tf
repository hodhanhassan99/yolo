variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}