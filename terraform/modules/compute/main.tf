#Create Compute Infrastructure
resource "aws_launch_template" "talend" {
  name                        = "talend-${var.instance_type}"
  instance_type               = var.instance_type
  key_name                    = var.ec2_key_name
  image_id                    = "ami-0648ea225c13e0729" //remove hardcoded values
 
  block_device_mappings {
    device_name = "/dev/sdh"
    
    ebs {
      volume_size = 20
      encrypted = "true"
      kms_key_id = var.kms_key_arn
    }
  }
  
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.security_group_name]
  }
  
  tag_specifications {
    resource_type = "instance"
    
    tags = {
      name = "talend"
      env  = "dev"
    }
  }
}

resource "aws_autoscaling_group""talend" {
  name                 = "talend"
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = data.aws_subnets.subnets.ids
  
  launch_template {
    id      = aws_launch_template.talend.id
    version = aws_launch_template.talend.latest_version
  }
}