resource "aws_security_group" "sg" {
  for_each = { for app in var.apps : app.name => app if app.deploy_type == "EC2" || app.deploy_type == "ASG" }
  
  name   = "${each.key}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.sg_rules.ingress
    content {
      description = each.value.description
      from_port   = each.value.from_port
      to_port     = each.value.to_port
      protocol    = each.value.protocol
      cidr_blocks = each.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.sg_rules
    content {
      description = each.value.description
      from_port   = each.value.from_port
      to_port     = each.value.to_port
      protocol    = each.value.protocol
      cidr_blocks = each.value.cidr_blocks
    }
  }
}

resource "aws_instance" "ec2" {
  for_each = local.flattened_ec2_apps

  ami             = each.value.config["ami"]
  instance_type   = each.value.config["instance_type"]
  subnet_id       = each.value.config["subnets"][0]
  security_groups = [aws_security_group.sg[each.key].id]
  user_data       = each.value.config["user_data"]

  root_block_device {
    volume_size = each.value.config["volume_size"]
  }
}

resource "aws_launch_configuration" "asg" {
  for_each = local.flattened_asg_apps

  name          = "${each.value.name}-launch-config"
  image_id      = each.value.ami
  instance_type = each.value.instance_type
  security_groups = [each.value.security_groups]

  user_data = each.value.user_data
  iam_instance_profile = each.value.iam_role

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  for_each = local.flattened_asg_apps

  desired_capacity     = each.value.asg.desired
  max_size             = each.value.asg.max
  min_size             = each.value.asg.min
  vpc_zone_identifier  = each.value.subnets
  launch_configuration = aws_launch_configuration.asg[each.key].id

  health_check_type        = "EC2"
  health_check_grace_period = 300
}


####ALB####
resource "aws_lb" "alb" {
  for_each = local.flattened_asg_apps

  name               = "${each.value.name}-alb"
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.sg[each.key].id]
  subnets            = each.value.alb.subnets

  tags = {
    Name = each.value.name
  }
}

resource "aws_lb_listener" "listener" {
  for_each = local.flattened_asg_apps

  load_balancer_arn = aws_lb.alb[each.key].arn
  port              = each.value.alb.listen_port
  protocol          = each.value.alb.protocol

  default_action {
    target_group_arn = aws_lb_target_group.target_group[each.key].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "target_group" {
  for_each = local.flattened_asg_apps

  name     = "${each.value.name}-tg"
  port     = each.value.alb.dest_port
  protocol = each.value.alb.protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "attachment" {
  for_each = local.flattened_asg_apps

  target_group_arn = aws_lb_target_group.target_group[each.key].arn
  target_id        = aws_instance.ec2[each.key].id
  port             = each.value.alb.dest_port
}