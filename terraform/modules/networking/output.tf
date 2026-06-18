output "app_gateway_public_ip" {
  value = azurerm_public_ip.appgw.ip_address
}
output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "appgw_subnet_cidr" {
  value = var.appgw_subnet_cidr
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "app_gateway_backend_pool_id" {
  value = tolist(azurerm_application_gateway.main.backend_address_pool[*].id)
}

output "backend_pool_ids" {
  value = [tolist(azurerm_application_gateway.main.backend_address_pool)[0].id]

}

output "health_probe_id" {
  value = tolist(azurerm_application_gateway.main.probe)[0].id
}

output "app_gateway_id" {
  value = azurerm_application_gateway.main.id
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "app_nsg_id" {
  value = azurerm_network_security_group.app_nsg.id
}

output "db_nsg_id" {
  value = azurerm_network_security_group.db_nsg.id
}
