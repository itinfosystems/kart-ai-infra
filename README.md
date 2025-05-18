# Terraform Kart IA Infrastructure Deployment

## Summary

This folder contains the infrastructure code the host the Kart AI application,

### kart-ai (account - 893567051722)

Foundation for shared Kart AI

-   Login to profile

    -   `aws sso login --profile itinfosystems`

-   `terraform init -backend-config=./environments/prod/terraform.hcl -reconfigure`
-   `terraform plan -var-file=./environments/prod/terraform.tfvars`

