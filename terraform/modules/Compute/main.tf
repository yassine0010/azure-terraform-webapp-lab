resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = var.vmss_name
  resource_group_name             = var.rg_name
  location                        = var.location
  sku                             = "Standard_B1s"
  instances                       = 2
  admin_username                  = var.admin_username
  disable_password_authentication = true
  single_placement_group          = false
  upgrade_mode                    = "Manual"   # ← back to Manual, permanently

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                          = "vmss-ip-config"
      primary                                       = true
      subnet_id                                     = var.app_subnet_id
      application_gateway_backend_address_pool_ids  = var.backend_pool_ids
    }
  }

  custom_data = base64encode(templatefile("${path.module}/startup.sh", {
    db_host     = var.db_host
    db_user     = var.db_user
    db_password = var.db_password
    db_name     = var.db_name
  }))

  # No health_probe_id, no rolling_upgrade_policy, no automatic_instance_repair
}