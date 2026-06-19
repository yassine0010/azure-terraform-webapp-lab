resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.rg_name
}
resource "azurerm_network_security_rule" "allow_mysql" {
  name      = "allow-mysql"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"
  source_port_range          = "*"
  source_address_prefix  = "10.0.1.0/24"
  destination_port_range = "3306"
  destination_address_prefix  = "*"

  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}
resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}