terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Instantiate our custom network module
module "production_network" {
  source = "../../modules/vpc" # Points to our blueprint directory

  # Pass in our custom parameters
  environment         = "production"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.10.0/24"
}

# 2. Instantiate Layer 3: The Application & Storage Tier
module "production_app_tier" {
  source = "../../modules/app_tier"

  environment       = "production"
  # --- DEPENDENCY LINKING ---
  # We pass the outputs from the network module directly as inputs here
  vpc_id            = module.production_network.vpc_id
  private_subnet_id = module.production_network.private_subnet_id
}

# Layer 3 (Part B): The Compute Engine
module "production_compute" {
  source                = "../../modules/compute"
  environment           = "production"
  private_subnet_id     = module.production_network.private_subnet_id
  
  # Inject dependencies from the app_tier module outputs
  app_security_group_id = module.production_app_tier.app_security_group_id
  redis_endpoint        = module.production_app_tier.redis_endpoint
}