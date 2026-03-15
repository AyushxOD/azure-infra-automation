resource "azurerm_resource_group" "main" {
  name     = "example-rg"
  location = "centralindia"
}

resource "azurerm_virtual_network" "main" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [azurerm_virtual_network.main]
}

resource "azurerm_public_ip" "main" {
  name                = "example-pubip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  

  sku               = "Standard"
  allocation_method = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "example-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Read the public key from ~/.ssh/azure_id_rsa.pub directly using the file function
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "example-vm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B2ats_v2"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.main.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key # Change this line
  }

  os_disk {
    name                 = "example-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 32
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# 1. Create the Security Group
resource "azurerm_network_security_group" "main" {
  name                = "ssh-access-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # In a real job, you'd put your home IP here
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id

}
# SECURITY ANALYSIS:
# The current configuration exposes the following critical vulnerabilities:
# 1. The Network Security Group (NSG) allows inbound SSH (port 22) from *any* source (source_address_prefix = "*").
#    - This means anyone on the internet can attempt to connect via SSH to your VM's public IP.
#    - Attackers can automatically scan Azure IP ranges for open SSH ports and attempt brute-force attacks.
#
# 2. Password authentication is enabled, and a weak, hardcoded password ("P@ssw0rd12345!") is used.
#    - Attackers can repeatedly try to guess the password (especially with a common pattern as shown).
#    - Once an attacker succeeds, they get full admin access to the VM.
#
# 3. No brute-force protections (e.g., fail2ban or similar) or multi-factor authentication are enabled.
#
# HOW TO BREAK IN AS AN ATTACKER:
# - Scan Azure IP address ranges for hosts with port 22 open.
# - Attempt SSH login with common usernames ("azureuser") and passwords (like the hardcoded example shown).
# - Success gives full access.

# RECOMMENDED FIXES:
# - Restrict NSG rule source_address_prefix to your own static IP or limited range, never "*".
# - Disable password authentication and require SSH key authentication.
# - Rotate admin credentials and never commit secrets to source control.
# - Use a just-in-time access approach if possible.