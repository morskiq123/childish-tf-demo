################################################
########### Load balancer components ###########
################################################

# Load balancer itself; it balances on the application layer

resource "aws_lb" "app_lb" {
    name = "${var.app_name}-lb"
    security_groups = [var.id_sg]
    subnets = [for id_subnet in var.id_subnets: id_subnet]
    # we pass multiple subnets in order to have HA
}

# Target group used to point to what will be load balanced

resource "aws_lb_target_group" "app_tg" {
    name = "${var.app_name}-tg"
    vpc_id = var.id_vpc
    port = var.lb_port 
    protocol = var.lb_protocol
    target_type = "instance"

    health_check {
        interval = "45"
        protocol = var.lb_protocol
        matcher = "200"
        unhealthy_threshold = "2"
    }
}

# Which port will be used for the load balancer

resource "aws_lb_listener" "app_listener" {
    load_balancer_arn = aws_lb.app_lb.id
    port = var.lb_port
    protocol = var.lb_protocol

    default_action {
        target_group_arn = aws_lb_target_group.app_tg.id
        type = "forward"
    }
}


################################################
######## Autoscaling group components ##########
################################################


# Launch template that will be used for the ASG. Here, we configure 
# the EC2 instances. In our case - image, initialization script, 
# network interface, iam, storage device

resource "aws_launch_template" "app_lt" {
  name_prefix = "${var.app_name}_"
  image_id = data.aws_ami.image.id
  instance_type = var.instance_type
  user_data = filebase64("${path.module}/apache_install.sh")
  # the script is uploaded and executed as part of the initialization

  # we require a network interface, because the instances we will be 
  # launching require a public ip; the network interface works as a virtual
  # network card, w/o it, the instances only have a private IP 
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.id_sg]
  }

   # allows the ec2s launched to access the dynamodb
  iam_instance_profile {
    arn = var.app_asg_service_role
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.lt_drive_size
    }
  }

  lifecycle {
    create_before_destroy = true
    # when you update the launch template, tf will create a new one 
    # before destroying the old one
  }

}


# Auto scaling group. This executes the autoscaling itself.

resource "aws_autoscaling_group" "app_asg"{

    launch_template {
        id = aws_launch_template.app_lt.id
        version = "$Latest"
    }

    name = "${var.app_name}"
    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = var.desired_size

    health_check_grace_period = 300
    health_check_type = "ELB" 
    # we are using an application load balancer
    
    # which subnets the ec2 instances will be launched in
    vpc_zone_identifier = [for id_subnet in var.id_subnets: id_subnet]
    target_group_arns = [aws_lb_target_group.app_tg.arn]

    enabled_metrics = [
        "GroupMinSize",
        "GroupMaxSize",
        "GroupDesiredCapacity",
        "GroupInServiceInstances",
        "GroupTotalInstances",
    ]

    metrics_granularity = "1Minute"

    depends_on = [aws_lb.app_lb]
}

################################################
############ Cloudwatch alarms ################
################################################

# scale up policy
resource "aws_autoscaling_policy" "cw_scale_up" {
  name = "${var.app_name}_asg_scale_up"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "1" # Increase instances by 1
  cooldown = var.scaling_cooldown
  policy_type = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "cw_scale_up_alarm" {
  alarm_name = "${var.app_name}_asg_scale_up_alarm"
  alarm_description = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = var.cpu_threshold_up 
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.app_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.cw_scale_up.arn]
}

# scale down policy
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_autoscaling_policy" "scale_down" {
  name = "${var.app_name}_asg_scale_down"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "-1" # Decrease instances by 1
  cooldown = "300"
  policy_type = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name = "${var.app_name}_asg_scale_down_alarm"
  alarm_description = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = var.cpu_threshold_down # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.app_asg.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}
