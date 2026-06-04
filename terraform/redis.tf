resource "aws_elasticache_subnet_group" "elasticache_subnet" {
  name        = "three-tier-elasticache-subnet"
  description = "redis subnet group"
  subnet_ids  = [aws_subnet.private_data_subnet_1.id, aws_subnet.private_data_subnet_2.id]
  tags = {
    Name = "three-tier-redis-sg"
  }
}


resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id         = "three-tier-redis-cluster"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.elasticache_subnet.name
  security_group_ids = [aws_security_group.redis_security_group.id]

  tags = {
    Name = "three-tier-redis-cluster"
  }
}

