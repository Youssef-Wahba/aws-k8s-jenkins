# resource "aws_eip" "k3s_eip" {
#     domain = "vpc"
# }

# # Associate the Elastic IP with the EC2 instance
# resource "aws_eip_association" "k3s_eip_assoc" {
#   instance_id   = aws_instance.k3s_instance.id
#   allocation_id = aws_eip.k3s_eip.id
# }