resource "azurerm_mysql_flexible_server" "main" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.rg_name

  # Authentication
  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  # Tier & Size
  sku_name = "B_Standard_B1ms" # Burstable B1ms

  # Storage
  storage {
    size_gb           = 20
    auto_grow_enabled = true # grows automatically when full
  }

  # Version
  version = "8.0.21"


  # Backup
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false


  # Connect to your VNet
  #connect to your DNS Zone for name resolution
  delegated_subnet_id = var.db_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id
  #Terraform might create MySQL server BEFORE DNS zone is linked to VNet Make sure the DNS link is created before the server, so it can register its name
  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}

# Create the database inside the server
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.db_name
  resource_group_name = var.rg_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4" # supports all characters + emojis
  collation           = "utf8mb4_unicode_ci"
}

# Private DNS Zone — so your VMs can find the DB by name
resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.rg_name
}

# Link DNS Zone to your VNet
resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-dns-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}