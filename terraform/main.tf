data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}

# Use Existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["Main VPC"]
  }
}

data "aws_subnet" "this" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Tier = "Public"
    Name = "Main Subnet"
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


# EC2 instance 
resource "aws_instance" "web" {
  ami                         = "ami-0648ea225c13e0729"
  subnet_id                   = data.aws_subnet.this.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  security_groups             = [aws_security_group.ec2_security_group.id]
  associate_public_ip_address = true
  tags = {
    Name = "WEB"

  }
  depends_on = [aws_security_group.ec2_security_group]
}

# Creating EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"

  tags = {
    Name = "EFS File System"
  }
}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_instance.web.subnet_id
  security_groups = [aws_security_group.ec2_security_group.id]
}

resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_mount_target.mount]
  connection {
    type        = var.connection_type
    user        = var.username
    private_key = tls_private_key.my_key.private_key_pem
    host        = aws_instance.web.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir efs",
      "sudo yum -y install amazon-efs-utils",
      "sleep 10",
      "sudo mount -t efs ${aws_efs_file_system.efs.id} efs/ "
    ]
  }
}