#!/bin/bash
set -e

# Multi-Environment Deployment Script
# Usage: ./deploy.sh <environment> [action]
# Examples:
#   ./deploy.sh dev apply
#   ./deploy.sh prod plan
#   ./deploy.sh prelive destroy

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|prelive|prod)$ ]]; then
    echo "Error: Environment must be dev, prelive, or prod"
    echo "Usage: $0 <environment> [action]"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    echo "Error: Action must be plan, apply, or destroy"
    echo "Usage: $0 <environment> [action]"
    exit 1
fi

echo "Deploying to $ENVIRONMENT environment..."

# Set environment-specific variables
ENV_DIR="environments/$ENVIRONMENT"
TFVARS_FILE="$ENV_DIR/terraform.tfvars"

# Check if environment config exists
if [[ ! -f "$TFVARS_FILE" ]]; then
    echo "Error: Environment config not found: $TFVARS_FILE"
    exit 1
fi

# Terraform operations
echo "Running Terraform $ACTION for $ENVIRONMENT..."
cd terraform/

# Initialize Terraform
terraform init

# Run the specified action
case $ACTION in
    "plan")
        terraform plan -var-file="../$TFVARS_FILE" -out="$ENVIRONMENT.tfplan"
        echo "Plan saved as $ENVIRONMENT.tfplan"
        ;;
    "apply")
        if [[ -f "$ENVIRONMENT.tfplan" ]]; then
            terraform apply "$ENVIRONMENT.tfplan"
        else
            terraform apply -var-file="../$TFVARS_FILE" -auto-approve
        fi
        
        # Get outputs for Ansible
        echo "Getting Terraform outputs..."
        ECR_URL=$(terraform output -raw ecr_repository_url)
        CERT_ARN=$(terraform output -raw self_signed_certificate_arn)
        CLUSTER_NAME=$(terraform output -raw cluster_name)
        AWS_REGION=$(terraform output -raw aws_region || echo "us-west-2")
        
        cd ../
        
        # Deploy with Helm via Ansible
        echo "Deploying application with Helm..."
        cd ansible/
        ansible-playbook playbooks/deploy-helm.yml \
            -e target_env=$ENVIRONMENT \
            -e docker_registry_url=$ECR_URL \
            -e self_signed_certificate_arn=$CERT_ARN \
            -e cluster_name=$CLUSTER_NAME \
            -e aws_region=$AWS_REGION
        
        echo "Deployment to $ENVIRONMENT completed!"
        echo "Get ALB URL: kubectl get ingress -n nginx-app-$ENVIRONMENT"
        ;;
    "destroy")
        terraform destroy -var-file="../$TFVARS_FILE" -auto-approve
        echo "Infrastructure destroyed for $ENVIRONMENT"
        ;;
esac
