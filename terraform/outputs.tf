# outputs.tf | Output repo url and ALB domain name

output "ecr_repo_url" {
  value = aws_ecr_repository.aws-ecr.repository_url
}

output "command" {
  value = "curl http://${aws_lb.application_load_balancer.dns_name}"
}
