# 1. Create NSG
resource "azurerm_network_security_group" "appgw_nsg" {
  name                = "appgw-nsg"
  location            = var.location
  resource_group_name = var.rg_name
}

# 2. Allow your users in (HTTP)
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "Internet" 
  source_port_range          = "*"  
  destination_port_range      = "80"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.appgw_nsg.name
}


# 4. Allow Azure to manage the gateway (MANDATORY)
resource "azurerm_network_security_rule" "allow_gateway_manager" {
  name                        = "allow-gateway-manager"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "GatewayManager"
  source_port_range          = "*"  
  destination_port_range      = "65200-65535"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.appgw_nsg.name
}

# 5. Allow Azure health checks (MANDATORY)
resource "azurerm_network_security_rule" "allow_azure_lb" {
  name                        = "allow-azure-lb"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range          = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.appgw_nsg.name
}

# 6. Attach NSG to AppGW subnet
resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = azurerm_subnet.appgw.id
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id
}