# EC2 Instance for Kubernetes/k3s
resource "aws_instance" "k3s_instance" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.generated_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # Enable public IP address
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    set -e

    echo "Installing k3s..."
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

    echo "Starting k3s service..."
    systemctl enable k3s
    systemctl start k3s

    echo "Setting kubeconfig permissions..."
    chmod 600 /etc/rancher/k3s/k3s.yaml
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # echo "Adding NGINX ingress Helm repo..."
    # helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    # helm repo update

    # making nginx namespace
    kubectl create namespace nginx-namespace

    echo "Installing NGINX"
    helm install ingress oci://registry-1.docker.io/bitnamicharts/nginx --namespace nginx-namespace

    # helm install nginx-ingress ingress-nginx/ingress-nginx \
    # --set controller.publishService.enabled=true
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
  key_name               = aws_key_pair.generated_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # Enable public IP address
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-docker-instance"
  }
}