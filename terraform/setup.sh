mkdir efs
sudo yum -y install amazon-efs-utils
sudo mount -t efs ${aws_efs_file_system.efs.id} efs/ 