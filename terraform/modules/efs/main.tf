#Creating EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  encrypted = var.encrypted

  tags = {
    Name = var.name
  }
}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_id
  security_groups = [var.sec_grp_id]
  depends_on      = [aws_efs_file_system.efs]
}
