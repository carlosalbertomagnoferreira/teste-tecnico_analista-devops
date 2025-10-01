resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "my-first-task"
  container_definitions    = file("task-definitions/task.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  cpu                      = 256
}