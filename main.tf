provider "aws" {
  region = "us-east-1"
}

# Variables
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "key_name" {
  description = "EC2 Key Pair Name"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "kubernetes-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "kubernetes-igw"
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = "public-subnet"
  }
}

# Route Table and Association
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "ec2_security_group" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access (for Jenkins)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS access (for Jenkins/Kubernetes API)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Instance for Kubernetes/k3s
resource "aws_instance" "k3s_instance" {
  ami           = "ami-0866a3c8686eaeeba" # Replace with a valid Ubuntu AMI
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id] # Use VPC security group IDs

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "k3s-instance"
  }
}

# EC2 Instance for Jenkins/Docker
resource "aws_instance" "jenkins_docker_instance" {
  ami           = "ami-0866a3c8686eaeeba" # Replace with a valid Ubuntu AMI
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id] # Use VPC security group IDs

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "jenkins-docker-instance"
  }
}

# ECR Repository
resource "aws_ecr_repository" "docker_repo" {
  name                 = "docker-repo"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "docker-repo"
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "k3s_instance_public_ip" {
  value = aws_instance.k3s_instance.public_ip
}

output "jenkins_docker_instance_public_ip" {
  value = aws_instance.jenkins_docker_instance.public_ip
}

output "ecr_repository_url" {
  value = aws_ecr_repository.docker_repo.repository_url
}