terraform {
  source = "../modules/aws"
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global_vars.yaml")))
}

inputs = {
  vpc_id = local.global_vars.vpc_id
  region = local.global_vars.region
  apps = [
    {
      name   = "my-ec2"
      deploy_type   = "EC2"
      config = {
        subnets       = local.global_vars.private_subnets
        ami           = "ami-xxxxx"
        instance_type = "t3.micro"
        volume_size   = 20
        user_data     = "#!/bin/bash\necho Hello"
        sg_rules      = {
            ingress = {
                description = "my description"
                from_port   = 0
                to_port     = 0
                protocol    = "-1"
                cidr_blocks = 
            }
            egress = {
                description = "my description"
                from_port   = 0
                to_port     = 0
                protocol    = "-1"
                cidr_blocks = 
            }
        }
      }
    },
    {
      name   = "my-asg"
      deploy_type   = "ASG"
      config = {
        subnets        = local.global_vars.private_subnets
        ami           = "ami-xxxxx"
        instance_type = "t3.micro"
        volume_size   = 20
        user_data     = "#!/bin/bash\necho Hello"
        sg_rules      = {
            ingress = {
                description = "my description"
                from_port   = 0
                to_port     = 0
                protocol    = "-1"
                cidr_blocks = 
            }
            egress = {
                description = "my description"
                from_port   = 0
                to_port     = 0
                protocol    = "-1"
                cidr_blocks = 
            }
        }
        asg           = {
            desired = 4
            max     = 6
            min     = 2
        }
        alb          =  {
            subnets      =
            listen_port  =
            dest_port    = 
            host         =
            path         =
            protocol     = "HTTP"
        }
      }
    }
  ]
}
