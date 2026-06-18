# root/variables.tf

# ── General ──────────────────────────────
variable "rg_name" {
  type    = string
  default = "my-networking-rg"
}

variable "location" {
  type    = string
  default = "francecentral"
}

# ── Networking ───────────────────────────
variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "appgw_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "app_gateway_name" {
  type    = string
  default = "app-gateway"
}

# ── Compute ──────────────────────────────
variable "vmss_name" {
  type    = string
  default = "app-vmss"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

# ── MySQL ────────────────────────────────
variable "mysql_server_name" {
  type    = string
  default = "myapp-db-prod"
}

variable "db_admin_username" {
  type      = string
  sensitive = true
}

variable "db_admin_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "myappdb"
}
