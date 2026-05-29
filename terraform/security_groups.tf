resource "aws_security_group" "nat_security_group" {
  vpc_id = aws_vpc.three_tier_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "three-tier-nat-security-group" }
}

resource "aws_security_group" "alb_security_group" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags   = { Name = "three-tier-alb-security-group" }
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags   = { Name = "three-tier-ecs-security-group" }
}

resource "aws_security_group" "aurora_security_group" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags   = { Name = "three-tier-aurora-security-group" }
}

resource "aws_security_group" "redis_security_group" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags   = { Name = "three-tier-redis-security-group" }
}