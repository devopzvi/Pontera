variable "apps" {
  description = "List of resources to deploy"
  type = list(object({
    name   = string   
    type   = string   
    config = map(any) 
  }))
}
variable "vpc_id" {
  description = "VPC where resources will be deployed"
  type        = string
}
variable "cidr_blocks" {
  description = "Allowed IP CIDR blocks"
  type        = list(string)
}
variable "ami" {
  description = "AMI ID for EC2 instances"
  type = string
}
variable "instance_type" {
  description = "Instance type for EC2 instances"
  type = string
}
variable "volume_size" {
  description = "Volume size for instances"
  type = number
}
variable "user_data" {
  description = "script for instance initialization"
  type = string
}
variable "iam_role" {
  description = "IAM role to be attached to instances (Instance Profile)"
  type = string
  default = "<some default iam_role arn>"
}
variable "asg" {
  description = "Auto Scaling Group configuration"
  type        = object({
    desired = number
    max     = number
    min     = number
  })
  default = null
}
variable "sg_rules" {
  description = "Security group rules"
  type        = object({
    ingress = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  })
  default = null
}
variable "alb" {
  description = "Application Load Balancer configuration"
  type        = object({
    subnets      = list(string)
    listen_port  = number
    dest_port    = number
    host         = string
    path         = string
    protocol     = string
  })
  default = null
}
variable "load_balancer_type" {
  description = "Type of load balancer"
  type = string
  default = "application"
}
variable "region" {
  description = "aws region"
  type = string
}
