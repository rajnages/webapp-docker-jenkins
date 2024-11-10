output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "master_instance_id" {
  description = "ID of the master instance"
  value       = aws_instance.instances["master"].id
}

output "master_public_ip" {
  description = "Public IP of the master instance"
  value       = aws_instance.instances["master"].public_ip
}

output "slave_instance_ids" {
  description = "IDs of the slave instances"
  value = {
    slave1 = aws_instance.instances["slave1"].id
    slave2 = aws_instance.instances["slave2"].id
  }
}

output "slave_private_ips" {
  description = "Private IPs of the slave instances"
  value = {
    slave1 = aws_instance.instances["slave1"].private_ip
    slave2 = aws_instance.instances["slave2"].private_ip
  }
}