aws_region = "us-east-1"
environment = "production"
vpc_cidr    = "10.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

instance_config = {
  master = {
    instance_type = "t3.medium"
    volume_size   = 100
  }
  slave1 = {
    instance_type = "t3.medium"
    volume_size   = 50
  }
  slave2 = {
    instance_type = "t3.medium"
    volume_size   = 50
  }
}

common_tags = {
  Environment = "Production"
  Project     = "Master-Slave-Cluster"
  Terraform   = "true"
  Owner       = "DevOps-Team"
}