# iam.tf | IAM Role Policies

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_task_exec_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name = "${var.app_name}-exec-task-role"
  tags = {
    Name = "${var.app_name}-iam-role"
    Environment = var.app_environment
  }
}

data "aws_iam_policy_document" "ecs_service_standard" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_service_standard" {
  policy = data.aws_iam_policy_document.ecs_service_standard.json
  name = "${var.app_name}-ecs-srv-pol"
}

resource "aws_iam_role_policy_attachment" "ecs_service_standard" {
  policy_arn = aws_iam_policy.ecs_service_standard.arn
  role = aws_iam_role.ecs_task_exec_role.name
}
