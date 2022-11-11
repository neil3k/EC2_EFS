#!/bin/sh

echo "start"
mkdir efs
yum -y install amazon-efs-utils
mount -t efs ${aws_efs_file_system.efs.id} efs/ 