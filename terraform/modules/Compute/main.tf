# VMSS — The scale set that creates and manages your VMs
resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = var.vmss_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard_B1s" # 1 vCPU, 1GB RAM ~$8/month
  instances           = 2              # start with 2 VMs
  admin_username      = var.admin_username

  # SSH key authentication — no passwords
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Ubuntu 20.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Network — place VMs in app-subnet + connect to App Gateway backend pool
  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "vmss-ip-config"
      primary   = true
      subnet_id = var.app_subnet_id

      # This connects VMSS directly to App Gateway backend pool
      application_gateway_backend_address_pool_ids = var.backend_pool_ids
    }
  }

  # Startup script — installs Node.js and starts your app when VM boots
  custom_data = base64encode(templatefile("${path.module}/startup.sh", {
  db_host     = var.db_host
  db_user     = var.db_user
  db_password = var.db_password
  db_name     = var.db_name
  }))

  # Health check — App Gateway uses this to know if VM is healthy
  health_probe_id = var.health_probe_id

  # Upgrade policy — how VMs get updated
  upgrade_mode = "Rolling" # updates VMs one by one, no downtime

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20 # update 20% of VMs at a time
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT0S"
  }

}

# Autoscaling — scale up/down based on CPU
resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "vmss-autoscale"
  resource_group_name = var.rg_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.main.id

  profile {
    name = "autoscale-profile"

    # Min and max number of VMs
    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    # Scale UP rule — too much CPU → add a VM
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M" # check every 1 minute
        statistic          = "Average"
        time_window        = "PT5M" # average over 5 minutes
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75 # if CPU > 75% → scale up
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"    # add 1 VM at a time
        cooldown  = "PT5M" # wait 5 min before scaling again
      }
    }

    # Scale DOWN rule — low CPU → remove a VM
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25 # if CPU < 25% → scale down
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1" # remove 1 VM at a time
        cooldown  = "PT5M"
      }
    }
  }
}
