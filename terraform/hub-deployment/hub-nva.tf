locals {
  hub-nva-location       = "westeurope"
  hub-nva-resource-group = "hub-nva-rg"
  prefix-hub-nva         = "hub-${local.hub-nva-location}-nva"
}

resource "azurerm_resource_group" "hub-nva-rg" {
  name     = "${local.prefix-hub-nva}-rg"
  location = local.hub-nva-location

  tags = {
    environment = local.prefix-hub-nva
  }
}

resource "azurerm_network_interface" "hub-nva-nic" {
  name                 = "${local.prefix-hub-nva}-nic"
  location             = azurerm_resource_group.hub-nva-rg.location
  resource_group_name  = azurerm_resource_group.hub-nva-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.prefix-hub-nva
    subnet_id                     = azurerm_subnet.hub-dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.36"
  }

  tags = {
    environment = local.prefix-hub-nva
  }
}

resource "azurerm_virtual_machine" "hub-nva-vm" {
  name                  = "${local.prefix-hub-nva}-vm"
  location              = azurerm_resource_group.hub-nva-rg.location
  resource_group_name   = azurerm_resource_group.hub-nva-rg.name
  network_interface_ids = [azurerm_network_interface.hub-nva-nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix-hub-nva}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = {
    environment = local.prefix-hub-nva
  }
}

resource "azurerm_virtual_machine_extension" "enable-routes" {
  name                 = "enable-iptables-routes"
  virtual_machine_id   = azurerm_virtual_machine.hub-nva-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"


  settings = <<SETTINGS
    {
        "fileUris": [
        "https://raw.githubusercontent.com/mspnp/reference-architectures/master/scripts/linux/enable-ip-forwarding.sh"
        ],
        "commandToExecute": "bash enable-ip-forwarding.sh"
    }
SETTINGS

  tags = {
    environment = local.prefix-hub-nva
  }
}

resource "azurerm_route_table" "hub-gateway-rt" {
  name                          = "hub-gateway-rt"
  location                      = azurerm_resource_group.hub-nva-rg.location
  resource_group_name           = azurerm_resource_group.hub-nva-rg.name
  disable_bgp_route_propagation = false

  tags = {
    environment = local.prefix-hub-nva

  }
}

resource "azurerm_route" "to-hub" {
  name                = "toHub"
  resource_group_name = azurerm_resource_group.hub-nva-rg.name
  route_table_name    = azurerm_route_table.hub-gateway-rt.name
  address_prefix      = "10.0.0.0/16"
  next_hop_type       = "VnetLocal"
}

resource "azurerm_subnet_route_table_association" "hub-gateway-rt-hub-vnet-gateway-subnet" {
  subnet_id      = azurerm_subnet.hub-gateway-subnet.id
  route_table_id = azurerm_route_table.hub-gateway-rt.id
  depends_on     = [azurerm_subnet.hub-gateway-subnet]
}
