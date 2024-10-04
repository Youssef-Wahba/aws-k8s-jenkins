# ECR Repository
resource "aws_ecr_repository" "docker_repo" {
  name                 = "nodejs-dns-resolver"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "nodejs-dns-resolver"
  }
}