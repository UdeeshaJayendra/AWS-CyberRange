output "target_instance_id" {
  description = "CyberRange target EC2 instance ID"
  value       = aws_instance.target.id
}

output "target_public_ip" {
  description = "CyberRange target public IP"
  value       = aws_instance.target.public_ip
}

output "target_public_dns" {
  description = "CyberRange target public DNS"
  value       = aws_instance.target.public_dns
}