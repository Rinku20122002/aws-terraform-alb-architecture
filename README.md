# AWS Application Load Balancer Architecture using Terraform

## Project Overview

This project demonstrates how to provision an AWS infrastructure using Terraform.

The architecture uses an Application Load Balancer (ALB) to distribute incoming HTTP traffic across EC2 instances deployed in different subnets.

The infrastructure is created using Infrastructure as Code (IaC) with Terraform.

## Architecture Components

The project includes the following AWS resources:

- **VPC:** Custom Virtual Private Cloud with CIDR `10.0.0.0/16`.
- **Public Subnets:** Two public subnets deployed across different Availability Zones.
- **Private Subnet:** A private subnet for an EC2 instance.
- **Internet Gateway:** Provides internet connectivity to public subnets.
- **Route Table:** Routes public subnet traffic through the Internet Gateway.
- **Security Groups:** Controls inbound and outbound traffic.
- **EC2 Instances:** Two EC2 instances hosting the application.
- **Application Load Balancer:** Distributes incoming HTTP traffic.
- **Target Group:** Registers EC2 instances and performs health checks.
- **Listener:** Listens on HTTP port 80 and forwards traffic to the target group.

## AWS Services Used

- Amazon VPC
- Amazon EC2
- Application Load Balancer
- Security Groups
- Internet Gateway
- Route Tables
- AWS IAM

## Tools and Technologies

- Terraform
- AWS CLI
- Linux (Ubuntu)
- Git
- GitHub

## Project Structure

```text
aws-terraform-alb-architecture/
├── .gitignore
├── .terraform.lock.hcl
├── main.tf
├── output.tf
├── provider.tf
├── user_data1.sh
├── user_data2.sh
└── variable.tf
```

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/Rinku20122002/aws-terraform-alb-architecture.git
```

### 2. Navigate to the Project Directory

```bash
cd aws-terraform-alb-architecture
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Format Terraform Configuration

```bash
terraform fmt
```

### 5. Validate Configuration

```bash
terraform validate
```

### 6. Review Execution Plan

```bash
terraform plan
```

### 7. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when Terraform asks for confirmation.

### 8. Access the Application

After deployment, retrieve the ALB DNS name:

```bash
terraform output alb_dns
```

Open the DNS name in a browser using HTTP.

## Cleanup

To avoid unnecessary AWS charges, destroy the infrastructure after testing:

```bash
terraform destroy
```

Type `yes` to confirm.

## Important Notes

- The ALB is configured in two public subnets across different Availability Zones.
- One EC2 instance is deployed in a public subnet and another in a private subnet.
- A NAT Gateway is not configured in this project.
- The private EC2 instance may require an alternative method for downloading application packages.
- Check EC2 target health before expecting traffic to reach both instances.
- Review Security Group rules before deploying this project in a production environment.

## Learning Objectives

Through this project, I practiced:

- AWS VPC and subnet configuration.
- Public and private subnet concepts.
- Internet Gateway and route table configuration.
- EC2 provisioning using Terraform.
- Application Load Balancer configuration.
- Target Groups and Health Checks.
- Security Group configuration.
- Terraform variables and outputs.
- Infrastructure deployment and cleanup.

---

## AWS Architecture Diagram

The following diagram illustrates the complete AWS infrastructure,
including networking, security, load balancing and compute resources.

flowchart TB
    USER(["Internet Users"])

    subgraph AWS["AWS Cloud - ap-southeast-2"]
        subgraph VPC["VPC - 10.0.0.0/16"]
            IGW["Internet Gateway"]

            RT["Public Route Table<br/>0.0.0.0/0 → IGW"]

            subgraph AZ1["Availability Zone: ap-southeast-2a"]
                subgraph PUB1["Public Subnet 1<br/>10.0.1.0/24"]
                    ALB["Application Load Balancer"]
                    ALBSG["ALB Security Group<br/>Inbound: HTTP 80"]
                    EC2SG1["EC2 Security Group"]
                    EC2_1["EC2 Instance 1<br/>Apache / Web Application"]
                end
            end

            subgraph AZ2["Availability Zone: ap-southeast-2b"]
                subgraph PUB2["Public Subnet 2<br/>10.0.3.0/24"]
                    ALB2["ALB Network Interface"]
                end

                subgraph PRIV["Private Subnet<br/>10.0.2.0/24"]
                    EC2_2["EC2 Instance 2<br/>Private Web Server"]
                end
            end

            TG["Target Group<br/>HTTP : 80<br/>Health Check: /"]
            LISTENER["ALB Listener<br/>HTTP : 80"]
        end
    end

    USER --> IGW
    IGW --> ALB
    ALB --- ALBSG
    ALBSG --> LISTENER
    LISTENER --> TG
    TG --> EC2_1
    TG --> EC2_2

    RT --> PUB1
    RT --> PUB2
    RT --> IGW

    EC2SG1 -. "Security Group" .-> EC2_1
    EC2SG1 -. "Security Group" .-> EC2_2
    ALB2 --- ALB

    classDef public fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef private fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef network fill:#fef3c7,stroke:#d97706,color:#78350f
    class ALB,ALB2,EC2_1,ALBSG public
    class EC2_2 private
    class IGW,RT,TG,LISTENER network



flowchart TB
    USER(["Internet User"])
    ALB["Application Load Balancer<br/>HTTP : 80"]

    subgraph ALB_FLOW["ALB Request Processing"]
        LISTENER["Listener<br/>Protocol: HTTP<br/>Port: 80"]
        RULE["Listener Default Rule<br/>Forward traffic"]
        TG["Target Group<br/>Protocol: HTTP<br/>Port: 80"]
        HC["Health Check<br/>Path: /<br/>Success Code: 200"]
    end

    subgraph TARGETS["Registered Targets"]
        EC2_1["EC2 Instance 1<br/>Public Subnet<br/>Apache Web Server"]
        EC2_2["EC2 Instance 2<br/>Private Subnet<br/>Web Server"]
    end

    USER -->|"HTTP Request"| ALB
    ALB --> LISTENER
    LISTENER --> RULE
    RULE --> TG
    TG -->|"Forward request"| EC2_1
    TG -->|"Forward request"| EC2_2
    HC -.->|"Check health"| EC2_1
    HC -.->|"Check health"| EC2_2

    EC2_1 -->|"HTTP Response"| TG
    EC2_2 -->|"HTTP Response"| TG
    TG --> ALB
    ALB --> USER

    
**Author:** Rinku Yadav

**GitHub:** https://github.com/Rinku20122002