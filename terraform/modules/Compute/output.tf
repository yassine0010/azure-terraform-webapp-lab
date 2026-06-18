output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.main.id
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.main.name
}

output "app_nsg_id" {
  value = azurerm_network_security_group.app_nsg.id
}