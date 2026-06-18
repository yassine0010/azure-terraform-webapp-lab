resource "azurerm_resource_group" "resource_group_name" {
  name     = var.rg_name
  location = var.location
}