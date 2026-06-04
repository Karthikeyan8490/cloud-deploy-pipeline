output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.flask_app.id
}

output "public_ip" {
  description = "Elastic IP address"
  value       = aws_eip.flask_eip.public_ip
}

output "public_dns" {
  description = "EC2 Public DNS"
  value       = aws_instance.flask_app.public_dns
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_eip.flask_eip.public_ip}"
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_eip.flask_eip.public_ip}"
}
