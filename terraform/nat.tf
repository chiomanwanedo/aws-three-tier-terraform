resource "aws_instance" "nat_instance" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.nat_security_group.id]
  key_name = "vee-eu-west-2"
  source_dest_check = false
  user_data = <<-EOF
  #!/bin/bash
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF
  
  tags = {
    Name = "three-tier-nat-instance"
  }
}

