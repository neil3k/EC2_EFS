output "mount_target_mound" {
  value = aws_efs_mount_target.mount.id
}

output "efs_file_system_id" {
  value = aws_efs_file_system.efs.id
}