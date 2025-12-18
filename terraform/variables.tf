variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "us-west-2"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID for ECS and ALB."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB and ECS tasks."
}

variable "alb_security_group_id" {
  type        = string
  description = "Existing security group ID attached to the ALB."
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name."
  default     = "fastapi-health-ecs"
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name."
  default     = "fastapi-health"
}

variable "service_name" {
  type        = string
  description = "ECS service name."
  default     = "fastapi-health"
}

variable "task_family" {
  type        = string
  description = "ECS task definition family name."
  default     = "fastapi-health"
}

variable "container_name" {
  type        = string
  description = "Container name in the task definition."
  default     = "app"
}

variable "container_port" {
  type        = number
  description = "Container port to expose."
  default     = 8011
}

variable "image_tag" {
  type        = string
  description = "Image tag to deploy from ECR."
  default     = "latest"
}

variable "task_cpu" {
  type        = string
  description = "Fargate CPU units."
  default     = "256"
}

variable "task_memory" {
  type        = string
  description = "Fargate memory in MiB."
  default     = "512"
}

variable "desired_count" {
  type        = number
  description = "Number of running tasks."
  default     = 1
}

variable "alb_name" {
  type        = string
  description = "Name of the application load balancer."
  default     = "fastapi-health-alb"
}

variable "target_group_name" {
  type        = string
  description = "Target group name (<= 32 chars)."
  default     = "fastapi-health-tg"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days."
  default     = 7
}
