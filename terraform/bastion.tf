resource "aws_security_group" "bastion_security_group" {
  name        = "three-tier-bastion-sg"
  description = "Temporary bastion for admin DB access"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["148.252.164.150/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-bastion-sg"
  }
}

resource "aws_security_group_rule" "aurora_ingress_bastion" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_security_group.id
  security_group_id        = aws_security_group.aurora_security_group.id
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0bcd4b196c3b85ced"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.bastion_security_group.id]
  associate_public_ip_address = true
  key_name                    = "vee-eu-west-2"

  tags = {
    Name = "three-tier-bastion-TEMPORARY"
  }
}