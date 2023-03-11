variable "project" {
  default     = "zomato"
  description = "project name"
}

variable "environment" {
  default     = "production"
  description = "project environemnt"
}

variable "region" {
  default = "ap-south-1"
}

variable "instance_ami" {
  default = "ami-09ba48996007c8b50"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "mykey"
}

variable "domain_name" {
  default = "getabhiram.tech"
}
