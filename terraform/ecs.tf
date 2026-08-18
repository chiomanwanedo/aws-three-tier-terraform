resource "aws_ecs_cluster" "ecs_cluster" {
  name = "three-tier-cluster"

  tags = {
    Name = "three-tier-ecs-cluster"
  }
}

container_definitions = jsonencode([...])

  lifecycle {
    ignore_changes = [container_definitions]
  }

      secrets = [
        { name = "DB_NAME", valueFrom = "${aws_secretsmanager_secret.secret_manager_secret.arn}:dbname::" },
        { name = "DB_USER", valueFrom = "${aws_secretsmanager_secret.secret_manager_secret.arn}:username::" },
        { name = "DB_PASSWORD", valueFrom = "${aws_secretsmanager_secret.secret_manager_secret.arn}:password::" }
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
    
  


resource "aws_ecs_service" "ecs_service" {
  name                   = "three-tier-service"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  launch_type            = "FARGATE"
  task_definition        = aws_ecs_task_definition.ecs_task_definition.id
  desired_count          = 2
  enable_execute_command = true

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
  lifecycle {
    ignore_changes = [task_definition]
  }
}



resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/three-tier-app"
  retention_in_days = 7

  tags = {
    Name = "three-tier-ecs-logs"
  }
}