
resource "azurerm_resource_group" "student-rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

# Cria rede virtual
resource "azurerm_virtual_network" "student-vnet" {
  name                = "student-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.student-rg.location
  resource_group_name = azurerm_resource_group.student-rg.name
}

# Cria subnets
resource "azurerm_subnet" "student-subnet" {
  name                 = "student-subnet"
  resource_group_name  = azurerm_resource_group.student-rg.name
  virtual_network_name = azurerm_virtual_network.student-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Cria IPs publicos
resource "azurerm_public_ip" "student-pip" {
  name                = "student-pip"
  location            = azurerm_resource_group.student-rg.location
  resource_group_name = azurerm_resource_group.student-rg.name
  allocation_method   = "Dynamic"
}

# Cria SG e uma regra de SSH
resource "azurerm_network_security_group" "student-nsg" {
  name                = "student-nsg"
  location            = azurerm_resource_group.student-rg.location
  resource_group_name = azurerm_resource_group.student-rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Cria NIC
resource "azurerm_network_interface" "student-nic" {
  name                = "student-nic"
  location            = azurerm_resource_group.student-rg.location
  resource_group_name = azurerm_resource_group.student-rg.name

  ip_configuration {
    name                          = "student_nic_configuration"
    subnet_id                     = azurerm_subnet.student-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.student-pip.id
  }
}

# Conecta SG com nic
resource "azurerm_network_interface_security_group_association" "student-nic-nsg" {
  network_interface_id      = azurerm_network_interface.student-nic.id
  network_security_group_id = azurerm_network_security_group.student-nsg.id
}

# # Cria nome generico para a chave ssh
# resource "random_pet" "ssh_key_name" {
#   prefix    = "student-ssh"
#   separator = "-"
# }

# # gera uma chave publica e uma privada
# resource "azapi_resource_action" "ssh_public_key_gen" {
#   type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   resource_id = azapi_resource.ssh_public_key.id
#   action      = "generateKeyPair"
#   method      = "POST"

#   response_export_values = ["publicKey", "privateKey"]
# }

# # associa o nome da chave criada aleatoriamente com a chave publica
# resource "azapi_resource" "ssh_public_key" {
#   type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   name      = random_pet.ssh_key_name.id
#   location  = azurerm_resource_group.student-rg.location
#   parent_id = azurerm_resource_group.student-rg.id
# }

# # salva a chave publica no diretorio principal
# resource "local_file" "private_key" {
#   content         = azapi_resource_action.ssh_public_key_gen.output.privateKey
#   filename        = "private_key.pem"
#   file_permission = "0600"
# }

# Cria a maquina virtual
resource "azurerm_linux_virtual_machine" "student-vm" {
  name                  = "student-vm"
  location              = azurerm_resource_group.student-rg.location
  resource_group_name   = azurerm_resource_group.student-rg.name
  network_interface_ids = [azurerm_network_interface.student-nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "student-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "student-vm"
  admin_username = var.username
  admin_password = var.vm_admin_password

  # admin_ssh_key {
  #   username   = var.username
  #   public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  # }

  depends_on = [
    azurerm_network_interface_security_group_association.student-nic-nsg,
    azurerm_network_interface.student-nic
  ]
}

# Gerar um inventario das VMs
resource "local_file" "hosts_cfg" {
  content = templatefile("inventory.tpl",
    {
      vm       = azurerm_linux_virtual_machine.student-vm
      username = var.username
      password = var.vm_admin_password
    }
  )
  filename = "./ansible/inventory.yml"
}


