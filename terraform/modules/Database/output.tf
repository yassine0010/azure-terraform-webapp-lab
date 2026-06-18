output "mysql_server_fqdn" {
  description = "Your app uses this to connect to the DB"
  value       = azurerm_mysql_flexible_server.main.fqdn
}
output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.main.name
}

output "database_name" {
  value = azurerm_mysql_flexible_database.main.name
}
