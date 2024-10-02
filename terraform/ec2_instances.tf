# EC2 Instance for Kubernetes/k3s
resource "aws_instance" "k3s_instance" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = local.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id] # Use VPC security group IDs

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "k3s-instance"
  }
}

# EC2 Instance for Jenkins/Docker
resource "aws_instance" "jenkins_docker_instance" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = local.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id] # Use VPC security group IDs

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "jenkins-docker-instance"
  }
}