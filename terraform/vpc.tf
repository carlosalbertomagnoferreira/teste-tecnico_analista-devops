resource "aws_default_vpc" "ecs-vpc" {
  tags = {
    Name = "ECS-VPC"
  }
}

resource "aws_default_subnet" "ecs_az1" {
  availability_zone = var.zone

  tags = {
    Name = "Default subnet for ${var.region}"
  }
}
