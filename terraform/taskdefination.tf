resource "aws_ecs_task_definition" "my_php_task" {
  family                   = "php-task"
  container_definitions    = file("task-definitions/php.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  cpu                      = 256
}

resource "aws_ecs_task_definition" "game_task" {
  family                   = "game-2048-task"
  container_definitions    = file("task-definitions/game.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  cpu                      = 256
}