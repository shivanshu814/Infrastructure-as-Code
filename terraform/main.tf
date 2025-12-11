# =====================================================
# Terraform Main Configuration
# =====================================================
# This file defines the main infrastructure components

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state configuration (uncomment after creating S3 bucket)
  # backend "s3" {
  #   bucket         = "devops-terraform-state-YOUR_ACCOUNT_ID"
  #   key            = "terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-lock"
  #   encrypt        = true
  # }
}

# =====================================================
# Provider Configuration
# =====================================================
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# =====================================================
# Data Sources
# =====================================================
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# =====================================================
# Modules
# =====================================================

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  backend_image       = module.ecr.backend_repository_url
  frontend_image      = module.ecr.frontend_repository_url
  alb_target_group_arn = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}
