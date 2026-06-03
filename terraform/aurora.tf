resource "aws_db_subnet_group" "aurora_database_sg" {
  name        = "three-tier-db-subnet"
  description = "Aurora subnet group"
  subnet_ids  = [aws_subnet.private_data_subnet_1.id, aws_subnet.private_data_subnet_2.id]
  tags = {
    Name = "three-tier-db-sg"
  }
}


resource "aws_rds_cluster" "rds_aurora" {
  cluster_identifier      = "three-tier-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = "15.17"
  availability_zones      = ["eu-west-2a", "eu-west-2b"]
  database_name           = "threetierdb"
  master_username         = "threetieruser"
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.aurora_database_sg.name
  backup_retention_period = 5
  vpc_security_group_ids  = [aws_security_group.aurora_security_group.id]
  skip_final_snapshot     = true

  preferred_backup_window = "07:00-09:00"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1.0
  }
}


resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "three-tier-aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.rds_aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.rds_aurora.engine
  engine_version     = aws_rds_cluster.rds_aurora.engine_version
}


