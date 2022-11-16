#Creating EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  encrypted = var.encrypted

  tags = {
    Name = var.name
  }
}

resource "aws_efs_mount_target" "mount" {
  for_each        = toset(data.aws_subnets.subnets.ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [var.sec_grp_id]
}