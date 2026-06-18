variable "server_name" {
  description = "MySQL server name — must be globally unique in Azure"
  type        = string

}

variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "admin_username" {
  type      = string
  sensitive = true
}

variable "admin_password" {
  type      = string
  sensitive = true # hides from logs and terminal output
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
}

variable "db_subnet_id" {
  description = "ID of DBSubnet — MySQL lives here"
  type        = string
}

variable "vnet_id" {
  description = "ID of your VNet — for DNS linking"
  type        = string
}