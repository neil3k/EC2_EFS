output "security_group_id" {
  value = aws_security_group.ec2_security_group.id
}

output "key_name" {
  value = aws_key_pair.deployer.key_name
}

output "security_group_name" {
  value = aws_security_group.ec2_security_group.name
}