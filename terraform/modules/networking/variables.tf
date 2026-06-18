variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}
variable "vnet_cidr" {
  description = "Virtual network CIDR"
  type        = string
}
variable "appgw_subnet_cidr" {
  description = "app gateway subnet"
  type        = string

}
variable "app_subnet_cidr" {
  description = "app subnet CIDR"
  type        = string
}
variable "db_subnet_cidr" {
  description = "database subnet CIDR"
  type        = string
}
variable "app_gateway_name" {
  description = "App Gateway name"
  type        = string
}