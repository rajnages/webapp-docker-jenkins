provider "aws" {
  region = var.aws_region
}

# Security Groups
resource "aws_security_group" "master" {
  name        = "${var.environment}-master-sg"
  description = "Security group for master instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-master-sg"
  })
}

resource "aws_security_group" "slave" {
  name        = "${var.environment}-slave-sg"
  description = "Security group for slave instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.master.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-slave-sg"
  })
}

# EC2 Instances
locals {
  instance_types = {
    master = "master"
    slave1 = "slave"
    slave2 = "slave"
  }
}

resource "aws_instance" "instances" {
  for_each = var.instance_config

  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type
  subnet_id     = each.key == "master" ? aws_subnet.public[0].id : aws_subnet.private[0].id

  vpc_security_group_ids = [
    local.instance_types[each.key] == "master" ? 
    aws_security_group.master.id : 
    aws_security_group.slave.id
  ]
  
  # Only add user data for master instance
  user_data = local.instance_types[each.key] == "master" ? file("master_userdata.sh") : null

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${each.key}"
    Role = local.instance_types[each.key]
  })

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}