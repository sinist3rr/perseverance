# alb.tf | Load Balancer Configuration

resource "aws_lb" "application_load_balancer" {
  name = "${var.app_name}-${var.app_environment}-alb"
  internal = false
  load_balancer_type = "application"
  subnets = aws_subnet.public.*.id
  security_groups = [aws_security_group.load_balancer_sg.id]
  tags = {
    Name = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "load_balancer_sg" {
  vpc_id = aws_vpc.aws-vpc.id
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.app_name}-${var.app_environment}-sg"
  }
}

resource "aws_lb_target_group" "target_group" {
  name = "${var.app_name}-${var.app_environment}-tg"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.aws-vpc.id
  health_check {
    enabled = true
    healthy_threshold = 5
    interval = 300
    protocol = "HTTP"
    matcher = "200"
    timeout = 60
    path = "/status"
    unhealthy_threshold = 5
  }
  tags = {
    Name = "${var.app_name}-lb-tg"
    Environment = var.app_environment
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
