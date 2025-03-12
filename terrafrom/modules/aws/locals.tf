locals {
  apps = {
     for app in var.apps : 
      app.name => {
        name             = app.name
        deploy_type      = app.deploy_type
        subnets          = try(app.config.subnets, null) #Comes from local.global_vars, but can be overriden. 
        ami              = try(app.config.ami, var.ami)
        instance_type    = try(app.config.instance_type, var.instance_type)
        volume_size      = try(app.config.volume_size, var.volume_size)
        user_data        = try(app.config.user_data, var.user_data)
        iam_role         = try(app.config.iam_role, var.iam_role)
        asg              = try(app.config.asg, var.asg)
        sg_rules         = try(app.config.sg_rules, var.sg_rules)
        alb              = try(app.config.alb, var.alb)
      }
  }

  ec2_apps = {
    for key, app in local.apps :
      key => app 
      if app.deploy_type == "EC2"
  }

  asg_apps = {
    for key, app in local.apps :
      key => app 
      if app.deploy_type == "ASG"
  }

  flattened_ec2_apps = flatten([
    for key, app in local.ec2_apps : [
      merge({ "name" = key }, app)
    ]
  ])

  flattened_asg_apps = flatten([
    for key, app in local.asg_apps : [
      merge({ "name" = key }, app)
    ]
  ])
}