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
  user_data = <<-EOF
    # Install k3s
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

    # Enable k3s service to start automatically
    systemctl enable k3s
    systemctl start k3s

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Add the NGINX ingress Helm repo and update
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update

    # Install NGINX ingress controller
    helm install nginx-ingress ingress-nginx/ingress-nginx

    # Expose the kubeconfig file to allow root access
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    chmod 644 /etc/rancher/k3s/k3s.yaml
  EOF
  tags = {
    Name = "k3s-instance"
  }
}

# EC2 Instance for Jenkins/Docker
resource "aws_instance" "jenkins_docker_instance" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Enable public IP address
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-docker-instance"
  }
}