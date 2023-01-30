output "eks_cluster_endpoint" {
  description = "Endpoint for EKS Control Plane"
  value       = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value     = aws_eks_cluster.aws_eks.certificate_authority
  sensitive = true
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.aws_eks.name
}