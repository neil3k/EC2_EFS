output "efs_file_system_id" {
  value = aws_efs_file_system.efs.id
}

output "mount_target_ids" {
  value = toset([for v in aws_efs_mount_target.mount : v.id])
}

output "efs_file_system_arn" {
  value = aws_efs_file_system.efs.arn
}

output "efs_file_system_dns" {
  value = aws_efs_file_system.efs.dns_name
}
