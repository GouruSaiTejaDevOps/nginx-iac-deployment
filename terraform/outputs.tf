

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "self_signed_certificate_arn" {
  description = "ARN of the self-signed SSL certificate"
  value       = module.eks.self_signed_certificate_arn
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "next_steps" {
  description = "Next steps after Terraform deployment"
  value = <<-EOT
    1. Configure kubectl: ${self.kubeconfig_command}
    2. Deploy NGINX: cd ../ansible && ansible-playbook playbooks/deploy.yml -e docker_registry_url=${module.ecr.repository_url}
    3. Get ALB URL: kubectl get ingress -n nginx-app
  EOT
}