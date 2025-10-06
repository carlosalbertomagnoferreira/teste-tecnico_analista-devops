resource "aws_ecs_service" "my_first_services" {
  name                = "service-test-devops"
  cluster             = aws_ecs_cluster.my_cluster.id
  task_definition     = aws_ecs_task_definition.my_php_task.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1

  network_configuration {
    subnets          = [aws_default_subnet.ecs_az1.id]
    assign_public_ip = true
  }
  enable_ecs_managed_tags = true
}

resource "aws_ecs_service" "my_game_services" {
  name                = "service-game-2048"
  cluster             = aws_ecs_cluster.my_cluster.id
  task_definition     = aws_ecs_task_definition.game_task.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1

  network_configuration {
    subnets          = [aws_default_subnet.ecs_az1.id]
    assign_public_ip = true
  }
  enable_ecs_managed_tags = true
}

