# Generate a new private/public key pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Use the generated public key to create the key pair on AWS
resource "aws_key_pair" "generated_key_pair" {
  key_name   = "my-generated-ec2-key-pair"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Save the generated private key to a local .pem file
resource "local_file" "save_private_key_pem" {
  filename = "${path.module}/../my-generated-ec2-key.pem"
  content  = tls_private_key.ec2_key.private_key_pem
  file_permission = "0400"
}

# Output the generated private key
output "private_key" {
  value     = tls_private_key.ec2_key.private_key_pem
  sensitive = true
}

# Output the key name for use in EC2 instances
output "key_name" {
  value = aws_key_pair.generated_key_pair.key_name
}

# Optional: Output the path of the saved .pem file
output "pem_file_path" {
  value = local_file.save_private_key_pem.filename
}