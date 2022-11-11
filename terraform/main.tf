data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}

# Use Existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["Main VPC"]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Generate new private key 
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = "efs-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Creating a new security group for EC2 instance with ssh and http inbound rules
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creating EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"

  tags = {
    Name = "EFS File System"
  }
}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.aws_subnets.subnets.ids[0]
  security_groups = [aws_security_group.ec2_security_group.id]
  depends_on      = [aws_efs_file_system.efs]
}

resource "aws_launch_configuration" "talend" {
  name                        = "talend"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo mkdir efs
sudo yum -y install amazon-efs-utils
mount -t efs ${aws_efs_file_system.efs.id} efs/
EOF
  security_groups             = [aws_security_group.ec2_security_group.id]
  key_name                    = aws_key_pair.deployer.key_name
  image_id                    = "ami-0648ea225c13e0729"
  depends_on                  = [aws_efs_mount_target.mount]
}

resource "aws_autoscaling_group" "talend" {
  name                 = "talend"
  launch_configuration = aws_launch_configuration.talend.id
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = [data.aws_subnets.subnets.ids[0]]
  depends_on           = [aws_efs_mount_target.mount]
}