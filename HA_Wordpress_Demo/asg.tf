resource "aws_placement_group" "test" {
  name     = "test"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "web-server" {
  name             = "nginx-webserver-asg"
  max_size         = 5
  min_size         = 2
  desired_capacity = 3
  force_delete     = true
  #placement_group           = aws_placement_group.test.id
  launch_configuration = aws_launch_configuration.web-server-launch-config.name
  vpc_zone_identifier  = ["subnet-05953dfd572b19719", "subnet-0c96f938594bb2024", "subnet-043e15fb2b4f1542c"]

  tag {
    key                 = "Name"
    value               = "nginx-web-server-asg"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_launch_configuration" "web-server-launch-config" {
  name          = "web_config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data     = file("./files/nginx-install.sh")
}