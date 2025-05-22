variable "region" {
  description = "The AWS region to deploy into."
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "environment" {
  description = "The environment to deploy into (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

locals {
  # "CIDR Block for Public Subnet 1"
  public_subnet_1_cidr = var.environment == "dev" ? "10.0.1.0/24" : "10.0.11.0/24"
  # CIDR Block for Public Subnet 2
  public_subnet_2_cidr = var.environment == "dev" ? "10.0.2.0/24" : "10.0.12.0/24"
  # EKS cluster role name
  eks_cluster_role_name = var.environment == "dev" ? "eks-cluster-role" : "prod-eks-cluster-role"
  # EC2 role name
  ec2_role_name = var.environment == "dev" ? "ec2_role" : "prod-ec2-role"
  # The maximum number of nodes in the EKS node group.
  desired_size = 3
  # The maximum number of nodes in the EKS node group.
  max_size = var.environment == "dev" ? 4 : 3
  # The minimum number of nodes in the EKS node group.
  min_size = 1
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-central-1b", "eu-central-1c"]
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  default     = "breachgg-portal"
}

variable "instance_types" {
  description = "The instance types for the EKS worker nodes."
  type        = list(string)
  default     = ["m5.xlarge"] # This instance type has 16 GB of RAM
}

variable "instance_disk_size" {
  description = "The instance disk size for the EKS worker nodes (in GB)"
  type        = number
  default     = 50
}
