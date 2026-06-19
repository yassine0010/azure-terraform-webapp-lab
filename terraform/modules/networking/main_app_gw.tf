
//public ip for app gateway
resource "azurerm_public_ip" "appgw" {
  name                = "appgw-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "main" {
  name                = "app-gateway"
  location            = var.location
  resource_group_name = var.rg_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }
  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = "/health" # your app has this endpoint ✅
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    host                = "127.0.0.1"
  }
  gateway_ip_configuration {
    name      = "gw-ip"
    subnet_id = azurerm_subnet.appgw.id
  }


  ssl_policy {
  policy_type = "Predefined"
  policy_name = "AppGwSslPolicy20220101"  # latest TLS 1.2/1.3 policy
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    protocol              = "Http"
    port                  = 8080
    cookie_based_affinity = "Disabled"
    probe_name            = "health-probe"    # ← add this line
    request_timeout       = 30               # ← add this line
  }
  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
  }
}