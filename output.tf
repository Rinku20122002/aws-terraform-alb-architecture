
# ============================================================
# 1. VPC OUTPUT
# Displays the ID of the VPC created by Terraform.
# ============================================================

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.myvpc.id
}


# ============================================================
# 2. APPLICATION LOAD BALANCER OUTPUT
# Displays the DNS name used to access the application
# through the Application Load Balancer.
# ============================================================

output "alb_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.test.dns_name
}


# ============================================================
# 3. EC2 PUBLIC IP OUTPUT
# Displays the public IP addresses of both EC2 instances.
# The private EC2 instance may return null because it has
# no public IP address assigned.
# ============================================================

output "ec2_public_ips" {
  description = "Public IP addresses of both EC2 instances"

  value = [
    aws_instance.instance1.public_ip,
    aws_instance.instance2.public_ip
  ]
}


# ============================================================
# 4. EC2 PRIVATE IP OUTPUT
# Displays the private IP addresses of both EC2 instances.
# Private IPs are used for internal communication within
# the VPC.
# ============================================================

output "ec2_private_ips" {
  description = "Private IP addresses of both EC2 instances"

  value = [
    aws_instance.instance1.private_ip,
    aws_instance.instance2.private_ip
  ]
}


# ============================================================
# 5. TARGET GROUP ARN OUTPUT
# Displays the ARN of the Target Group associated with
# the Application Load Balancer.
# ============================================================

output "target_group_arn" {
  description = "ARN of the Application Load Balancer Target Group"
  value       = aws_lb_target_group.my_tg.arn
}
