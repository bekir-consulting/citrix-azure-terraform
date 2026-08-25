# Citrix-on-Azure Infrastructure - Terraform

Automated deployment of a Citrix worker infrastructure on Microsoft Azure using Terraform.

## What this deploys

- Resource Group
- Virtual Network (VNet) with Citrix Worker Subnet
- Network Security Group with Citrix-specific rules (ICA 1494, CGP 2598, RDP 3389)
- Windows Server 2022 VM (Citrix Worker)
- Public IP and Network Interface

## Prerequisites

- Terraform >= 1.1.0
- Azure CLI installed and logged in
- Azure Service Principal with Contributor role

## Usage

    terraform init
    terraform plan
    terraform apply

## Security

- Admin password is passed as a variable (never hardcoded)
- NSG rules restrict ICA and RDP to internal network only (10.0.0.0/16)
- Sensitive values marked in variables.tf

## Author

Bekir Ugurlu | Citrix & Azure Architect | ugurlu@bekirconsulting.de
