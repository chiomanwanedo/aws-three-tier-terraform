resource "aws_lb" "alb" {
  name               = "three-tier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

   tags = {
    Name = "three-tier-alb"
  }
}



resource "aws_lb_target_group" "alb_target_group" {
  name     = "three-tier-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.three_tier_vpc.id
  target_type = "ip"

tags = {
    Name = "three-tier-lb-target-group"
  }
}


resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  
default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

