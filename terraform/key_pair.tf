resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "my-generated-ec2-key-pair"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.ec2_key.private_key_pem
  sensitive = true
}