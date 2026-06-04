resource "aws_ecs_cluster" "ecs_cluster" {
  name = "three-tier-cluster"

  tags = {
    Name = "three-tier-ecs-cluster"
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "three-tier-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "three-tier-app"
      image     = "545586474482.dkr.ecr.eu-west-2.amazonaws.com/three-tier-repository:v2"
      cpu       = 256
      memory    = 512
      essential = true
      environment = [
        { name = "DB_HOST", value = tostring(aws_rds_cluster.rds_aurora.endpoint) },
        { name = "DB_NAME", value = "threetierdb" },
        { name = "DB_USER", value = "threetieruser" },
        { name = "DB_PASSWORD", value = tostring(var.db_password) },
        { name = "REDIS_HOST", value = tostring(aws_elasticache_cluster.elasticache_cluster.cache_nodes[0].address) }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/three-tier-app"
          "awslogs-region"        = "eu-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "three-tier-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.ecs_task_definition.id
  desired_count   = 2
  network_configuration {
    subnets          = [aws_subnet.private_app_subnet_1.id, aws_subnet.private_app_subnet_2.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "three-tier-app"
    container_port   = 80
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/three-tier-app"
  retention_in_days = 7

  tags = {
    Name = "three-tier-ecs-logs"
  }
}