# root/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ─────────────────────────────────────────
# NETWORKING MODULE
# ─────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  # Basic
  rg_name   = var.rg_name
  location  = var.location
  vnet_cidr = var.vnet_cidr

  # Subnets
  appgw_subnet_cidr = var.appgw_subnet_cidr
  app_subnet_cidr   = var.app_subnet_cidr
  db_subnet_cidr    = var.db_subnet_cidr

  # App Gateway
  app_gateway_name = var.app_gateway_name
}

# ─────────────────────────────────────────
# MYSQL MODULE
# ─────────────────────────────────────────
module "mysql" {
  source = "./modules/Database"

  # Basic
  rg_name  = var.rg_name
  location = var.location

  # Server
  server_name    = var.mysql_server_name
  admin_username = var.db_admin_username
  admin_password = var.db_admin_password
  db_name        = var.db_name

  # Networking — comes from networking module
  db_subnet_id = module.networking.db_subnet_id
  vnet_id      = module.networking.vnet_id
}

# ─────────────────────────────────────────
# COMPUTE MODULE
# ─────────────────────────────────────────
module "compute" {
  source = "./modules/Compute"

  # Basic
  rg_name   = var.rg_name
  location  = var.location
  vmss_name = var.vmss_name

  # VM Access
  admin_username = var.vm_admin_username
  ssh_public_key = var.ssh_public_key

  # Networking — comes from networking module
  app_subnet_id     = module.networking.app_subnet_id
  appgw_subnet_cidr = module.networking.appgw_subnet_cidr

  # App Gateway — comes from networking module
  backend_pool_ids = module.networking.backend_pool_ids
  health_probe_id  = module.networking.health_probe_id
  app_gateway_id   = module.networking.app_gateway_id

  # Database — comes from mysql module
  db_host     = module.mysql.mysql_server_fqdn
  db_name     = module.mysql.database_name
  db_user     = var.db_admin_username
  db_password = var.db_admin_password
}
