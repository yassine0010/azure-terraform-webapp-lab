output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.main.id
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.main.name
}
