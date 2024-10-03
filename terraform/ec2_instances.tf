# EC2 Instance for Kubernetes/k3s
resource "aws_instance" "k3s_instance" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name                 = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Enable public IP address
  associate_public_ip_address = true

  tags = {
    Name = "k3s-instance"
  }
}

# EC2 Instance for Jenkins/Docker
resource "aws_instance" "jenkins_docker_instance" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name                 = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Enable public IP address
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-docker-instance"
  }
}