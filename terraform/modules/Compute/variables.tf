variable "vmss_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_username" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  description = "SSH public key to access VMs via Bastion"
  type        = string
  sensitive   = true
}

variable "app_subnet_id" {
  description = "ID of app-subnet where VMs will live"
  type        = string
}

variable "appgw_subnet_cidr" {
  description = "CIDR of App Gateway subnet e.g. 10.0.0.0/24"
  type        = string
}

variable "backend_pool_ids" {
  description = "App Gateway backend pool IDs — VMSS registers here"
  type        = list(string)
}

variable "health_probe_id" {
  description = "App Gateway health probe ID"
  type        = string
}

variable "app_gateway_id" {
  description = "App Gateway ID — VMSS waits for it to be ready"
  type        = string
}
variable "db_host" {
  description = "MySQL server hostname"
  type        = string
}
variable "db_name" {
  description = "MySQL database name"
  type        = string
}
variable "db_user" {
  description = "MySQL database username"
  type        = string
}
variable "db_password" {
  description = "MySQL database password"
  type        = string
  sensitive   = true
}