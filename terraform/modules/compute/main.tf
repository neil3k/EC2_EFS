#Create Compute Infrastructure
resource "aws_launch_configuration" "talend" {
  name                        = "talend"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo mkdir efs
sudo yum -y install amazon-efs-utils
mount -t efs ${var.efs_id} efs/
EOF
  security_groups             = [var.security_group_name]
  key_name                    = var.ec2_key_name
  image_id                    = "ami-0648ea225c13e0729"
}

resource "aws_autoscaling_group" "talend" {
  for_each             = toset(data.aws_subnets.subnets.ids)
  name                 = "talend"
  launch_configuration = aws_launch_configuration.talend.id
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = each.value
}