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

# Additional output for all instances' public IPs
output "instance_public_ips" {
  value = [
    aws_instance.k3s_instance.public_ip,
    aws_instance.jenkins_docker_instance.public_ip
  ]
}