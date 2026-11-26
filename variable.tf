
# ============================================================
# 1. VPC CONFIGURATION
# Defines the CIDR range for the entire VPC.
# ============================================================

variable "vpc_value" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}


# ============================================================
# 2. AVAILABILITY ZONES
# Defines the AWS Availability Zones for subnet deployment.
# Public subnets must be deployed in different AZs for ALB HA.
# ============================================================

variable "availability_zone_value1" {
  description = "Availability Zone for Public Subnet 1"
  default     = "ap-southeast-2a"
}

variable "availability_zone_value2" {
  description = "Availability Zone for Private Subnet and Public Subnet 2"
  default     = "ap-southeast-2b"
}


# ============================================================
# 3. EC2 CONFIGURATION
# Defines the AMI and instance type used by EC2 instances.
# ============================================================

variable "ami_value" {
  description = "AMI ID used to launch EC2 instances"
  default     = "ami-06259b63260eddc13"
}

variable "instance_value" {
  description = "EC2 instance type"
  default     = "t3.micro"
}
