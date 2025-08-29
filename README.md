# NGINX IaC Deployment

Deploy NGINX applications to AWS EKS with Terraform, Ansible, and Helm across multiple environments.

## Structure

```
nginx-iac-deployment/
├── app/                    # NGINX application
├── terraform/             # Infrastructure (modules)
├── helm/                  # Kubernetes charts
├── environments/          # Environment configs (dev/prelive/prod)
├── ansible/              # Deployment automation
└── .github/workflows/    # CI/CD pipelines
```

## Quick Start

### Deploy to Environment

```bash
# Deploy to development
./deploy.sh dev apply

# Deploy to pre-live
./deploy.sh prelive apply

# Deploy to production
./deploy.sh prod apply
```

### Prerequisites

- AWS CLI configured
- Docker installed
- Ansible installed
- kubectl installed

## Environments

| Environment | Scale | Resources | Purpose |
|-------------|-------|-----------|---------|
| dev | 1 replica | Minimal | Development |
| prelive | 2 replicas | Medium | Staging |
| prod | 3 replicas | Full | Production |

## Endpoints

- `/` - Main page
- `/phrase` - Returns 200 OK
- `/health` - Health check
- `/env` - Environment info

## CI/CD

Automated workflows trigger on push to:
- `dev` branch → Development environment
- `staging` branch → Pre-live environment  
- `prod` branch → Production environment

Features:
- Docker image build and push to ECR
- Vulnerability scanning with Trivy
- Automated deployment with Helm
- Smoke tests

## Manual Deployment

### Infrastructure Only
```bash
cd terraform/
terraform apply -var-file="../environments/dev/terraform.tfvars"
```

### Application Only
```bash
cd ansible/
ansible-playbook playbooks/deploy-helm.yml -e target_env=dev
```

## Access Application

```bash
# Get ALB URL
kubectl get ingress -n nginx-app-<env>

# Test endpoints
curl http://ALB-DNS-NAME/phrase
curl http://ALB-DNS-NAME/health
```

## Cleanup

```bash
./deploy.sh <environment> destroy
```

Ready to deploy: `./deploy.sh dev apply`