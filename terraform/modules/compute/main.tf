#Create Compute Infrastructure
resource "aws_launch_configuration" "talend" {
  name                        = "talend-${var.instance_type}"
  instance_type               = var.instance_type
  associate_public_ip_address = var.public_ip
  user_data                   = <<EOF
#!/bin/bash
sudo mkdir efs
sudo yum -y install amazon-efs-utils
sudo pip3 install botocore --upgrade
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${var.efs_dns}:/ efs
EOF
  security_groups             = [var.security_group_name]
  key_name                    = var.ec2_key_name
  image_id                    = "ami-0648ea225c13e0729" //remove hardcoded values
}

resource "aws_autoscaling_group""talend" {
  name                 = "talend"
  launch_configuration = aws_launch_configuration.talend.id
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = data.aws_subnets.subnets.ids
}