resource "aws_ecs_service" "my_first_services" {
  name                = "service-test-devops"
  cluster             = aws_ecs_cluster.my_cluster.id
  task_definition     = aws_ecs_task_definition.my_first_task.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1

  network_configuration {
    subnets          = [aws_default_subnet.ecs_az1.id]
    assign_public_ip = true
  }
  enable_ecs_managed_tags = true
}

data "aws_network_interfaces" "network_eni" {
  tags = {
    "aws:ecs:serviceName" = aws_ecs_service.my_first_services.name
  }
  filter {
    name   = "description"
    values = ["ECS elastic network interface*"]
  }
}

data "aws_network_interface" "network_eni_details" {
  id = data.aws_network_interfaces.network_eni.ids[0] # Assuming one ENI per service for simplicity
}

output "ecs_task_public_ip" {
  value       = data.aws_network_interface.network_eni_details.public_ip
  description = "The public IP address of the ECS Fargate task."
}