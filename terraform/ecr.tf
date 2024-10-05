# ECR Repository
resource "aws_ecr_repository" "docker_repo" {
  name                 = "docker-repo"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "docker-repo"
  }
}