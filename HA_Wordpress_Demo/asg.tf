# Collection of EC2 Instances for autoscaling purposes
resource "aws_autoscaling_group" "web-server" {
  name             = "nginx-webserver-asg"
  max_size         = 4
  min_size         = 1
  desired_capacity = 2
  force_delete     = true
  launch_configuration = aws_launch_configuration.web-server-launch-config.name
  vpc_zone_identifier  = [aws_subnet.public1.id, aws_subnet.public2.id]
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      load_balancers, target_group_arns
    ]
  }
  tag {
    key                 = "Name"
    value               = "nginx-web-server-asg"
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }
}

# Initial configuration for all EC2 instances in the group
## Metadata, specs, user data / scripts, etc.
resource "aws_launch_configuration" "web-server-launch-config" {
  name          = "web_config"
  image_id = var.ami_id
  instance_type = "t2.micro"
  #user_data = data.template_file.asg_init.rendered
  lifecycle {
    create_before_destroy = true
  }
}