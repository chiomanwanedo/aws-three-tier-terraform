resource "aws_ecr_repository" "ecr_repository" {
  name                 = "three-tier-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "three-tier-image-repository"
  }
}