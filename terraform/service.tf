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
  wait_for_steady_state   = true

  tags = {
    name = "service-test-devops"
  }

}

data "aws_network_interface" "interface_tags" {
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = ["service-test-devops*"]
  }
}

output "public_ip" {
  value = data.aws_network_interface.interface_tags.association[0].public_ip
}