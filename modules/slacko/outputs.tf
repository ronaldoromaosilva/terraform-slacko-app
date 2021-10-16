output "slacko-mongodb" {
  value = aws_instance.mongodb-EC2.private_ip
}
output "slacko-app" {
  value = aws_instance.slacko-EC2.public_ip
}