# Citrix-on-Azure Infrastructure - Terraform

Automated deployment of a Citrix worker infrastructure on Microsoft Azure using Terraform.

## What this deploys
- Resource Group
- Virtual Network (VNet) with Citrix Worker Subnet
- Network Security Group with Citrix-specific rules (ICA 1494, CGP 2598, RDP 3389)
- Windows Server 2022 VM (Citrix Worker)
- Public IP and Network Interface

## Usage
```bash
terraform init
terraform plan
terraform apply
```

## Author
Bekir Ugurlu | Citrix & Azure Architect | ugurlu@bekirconsulting.de
