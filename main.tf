
# ============================================================
# 1. VPC
# Creates the main Virtual Private Cloud for this architecture.
# ============================================================

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_value

  tags = {
    Name = "Rinku_VPC"
  }
}


# ============================================================
# 2. SUBNETS
# Creates two public subnets and one private subnet.
#
# Public Subnet 1: 10.0.1.0/24
# Private Subnet:  10.0.2.0/24
# Public Subnet 2: 10.0.3.0/24
# ============================================================

# First public subnet
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone_value1
  map_public_ip_on_launch = true

  tags = {
    Name = "Rinku-Public-Subnet1"
  }
}

# Private subnet
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone_value2

  tags = {
    Name = "Rinku-Private-Subnet"
  }
}

# Second public subnet
resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.availability_zone_value2
  map_public_ip_on_launch = true

  tags = {
    Name = "Rinku-Public-Subnet2"
  }
}


# ============================================================
# 3. INTERNET GATEWAY
# Connects the VPC to the public internet.
# ============================================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "My_Internet_Gateway"
  }
}


# ============================================================
# 4. PUBLIC ROUTE TABLE
# Routes internet-bound traffic (0.0.0.0/0) through the IGW.
# ============================================================

resource "aws_route_table" "mytable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Route-RT"
  }
}

# Associate the first public subnet with the public route table.
resource "aws_route_table_association" "associate-rt1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.mytable.id
}

# Associate the second public subnet with the public route table.
resource "aws_route_table_association" "associate-rt2" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.mytable.id
}


# ============================================================
# 5. EC2 SECURITY GROUP
# Controls inbound and outbound traffic for EC2 instances.
# ============================================================

resource "aws_security_group" "rakhsabal" {
  name   = "allow_tls"
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Gaurd"
  }
}

# HTTP access rule (currently allows all IPv4 sources).
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_0" {
  security_group_id = aws_security_group.rakhsabal.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# SSH access rule (currently allows all IPv4 sources).
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_1" {
  security_group_id = aws_security_group.rakhsabal.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allows all outbound traffic from EC2 instances.
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.rakhsabal.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# ============================================================
# 6. ALB SECURITY GROUP
# Controls traffic entering and leaving the Application Load Balancer.
# ============================================================

resource "aws_security_group" "rakhsabal1" {
  name   = "allow_tls_lb"
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Gaurd_For_LB"
  }
}

# Allows HTTP requests from the internet to the ALB.
resource "aws_vpc_security_group_ingress_rule" "alb_ingress" {
  security_group_id = aws_security_group.rakhsabal1.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allows outbound traffic from the ALB.
resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.rakhsabal1.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# ============================================================
# 7. EC2 KEY PAIR
# Registers the public SSH key with AWS for EC2 authentication.
# ============================================================

resource "aws_key_pair" "deployer" {
  key_name   = "Rinku-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}


# ============================================================
# 8. EC2 INSTANCES
# Instance 1: Deployed in the first public subnet.
# Instance 2: Deployed in the private subnet.
# User data scripts configure the web servers during launch.
# ============================================================

resource "aws_instance" "instance1" {
  ami                    = var.ami_value
  instance_type          = var.instance_value
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.rakhsabal.id]
  user_data              = file("user_data1.sh")
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "Instance1"
  }
}

resource "aws_instance" "instance2" {
  ami                    = var.ami_value
  instance_type          = var.instance_value
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.rakhsabal.id]
  user_data              = file("user_data2.sh")
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "Instance2"
  }
}


# ============================================================
# 9. APPLICATION LOAD BALANCER
# Creates a public-facing Application Load Balancer.
# It spans two public subnets for Availability Zone redundancy.
# ============================================================

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rakhsabal1.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet3.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}


# ============================================================
# 10. TARGET GROUP
# Registers EC2 instances as targets.
# Health checks use HTTP on port 80 and path "/".
# ============================================================

resource "aws_lb_target_group" "my_tg" {
  name     = "Rinku-TG"
  protocol = "HTTP"
  port     = 80
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Rinku-TG"
  }
}


# ============================================================
# 11. TARGET GROUP ATTACHMENTS
# Registers both EC2 instances with the target group.
# ============================================================

resource "aws_lb_target_group_attachment" "ec2_1" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_2" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.instance2.id
  port             = 80
}


# ============================================================
# 12. ALB LISTENER
# Listens for incoming HTTP requests on port 80.
# Forwards requests to the configured target group.
# ============================================================

resource "aws_lb_listener" "my_listner" {
  load_balancer_arn = aws_lb.test.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}
