variable "region" {
  description = "Define what region the instance will be deployed"
  default     = "us-east-1"
}

variable "zone" {
  description = "Define what availability_zone the instance will be deployed"
  default     = "us-east-1a"
}

variable "ecs_name" {
  description = "Name of cluster k8s"
  default     = "teste-devops"
}

variable "env" {
  description = "Enviroment of the application"
  default     = "test"
}

variable "app_key_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing Laravel's APP_KEY"
  type        = string
}
