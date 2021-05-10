# ecs.tf | Elastic Container Service Cluster and Tasks Configuration

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.app_name}-${var.app_environment}-cluster"
  capacity_providers = ["FARGATE"]
  tags = {
    Name = "${var.app_name}-ecs"
    Environment = var.app_environment
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  container_definitions = <<TASK_DEFINITION
  [
    {
    "name": "${var.app_name}-${var.app_environment}-container",
    "essential": true,
    "image": "${aws_ecr_repository.aws-ecr.repository_url}:latest",
    "cpu": 256,
    "memory": 512,
    "environment": [
      {
        "name": "API_KEY",
        "value": "${var.nasa_api_key}"
      }
    ],
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log_group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.app_name}-${var.app_environment}"
        }
      }
    }
  ]
  TASK_DEFINITION
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory = "512"
  cpu = "256"
  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn = aws_iam_role.ecs_task_exec_role.arn
  family = "${var.app_name}-task"
  tags = {
    Name = "${var.app_name}-ecst-td"
    Environment = var.app_environment
  }
}

resource "aws_ecs_service" "aws-ecs-service" {
  name = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition = aws_ecs_task_definition.aws-ecs-task.arn
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count = 1
  force_new_deployment = true
  network_configuration {
    subnets = aws_subnet.private.*.id
    assign_public_ip = true
    security_groups = [aws_security_group.service_security_group.id]
  }
  load_balancer {
    container_name = "${var.app_name}-${var.app_environment}-container"
    container_port = 80
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  depends_on = [aws_lb_listener.lb_listener]
}

resource "aws_security_group" "service_security_group" {
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
    Name = "${var.app_name}-service-sg"
    Environment = var.app_environment
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.app_name}-${var.app_environment}-logs"
  tags = {
    Name = "${var.app_name}-${var.app_environment}-logs"
    Environment = var.app_environment
  }
}
