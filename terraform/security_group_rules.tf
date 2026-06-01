resource "aws_security_group_rule" "alb_egress_ecs" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]

}


resource "aws_security_group_rule" "ecs_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.alb_security_group.id
}


resource "aws_security_group_rule" "ecs_egress_http" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.nat_security_group.id
}

resource "aws_security_group_rule" "ecs_egress_https" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.nat_security_group.id
}


resource "aws_security_group_rule" "ecs_egress_aurora" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.aurora_security_group.id
}

resource "aws_security_group_rule" "ecs_egress_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.redis_security_group.id
}


resource "aws_security_group_rule" "redis_egress_ecs" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_security_group_rule" "redis_ingress_ecs" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}



resource "aws_security_group_rule" "aurora_ingress_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aurora_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_security_group_rule" "aurora_egress_ecs" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aurora_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}