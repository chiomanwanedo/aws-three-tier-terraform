output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}


output "alb_target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}


output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}


output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.ecs_task_definition.arn
}


output "aurora_endpoint" {
  value = aws_rds_cluster.rds_aurora.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.elasticache_cluster.cache_nodes[0].address
}

output "ecr" {
  value = aws_ecr_repository.ecr_repository.repository_url
}