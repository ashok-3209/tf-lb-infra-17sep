module "azurerm_resource_group" {
  source                  = "../../Modules/azurerm_resource_group"
  resource_group_name     = "dev-rg-ashok01"
  resource_group_location = "West US"
}

####Netwroking Modules############
module "azurerm_virtual_network" {
  depends_on           = [module.azurerm_resource_group]
  source               = "../../Modules/azurerm_virtual_network"
  virtual_network_name = "todoapp_vnet"
  address_space        = ["10.0.0.0/16"]
  location             = "West US"
  resource_group_name  = "dev-rg-ashok01"
}

module "azurerm_frontend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../../Modules/azurerm_subnet"
  subnet_name          = "frontend-subnet"
  resource_group_name  = "dev-rg-ashok01"
  virtual_network_name = "todoapp_vnet"
  address_prefixes     = ["10.0.1.0/24"]

}

module "azurerm_backend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../../Modules/azurerm_subnet"
  subnet_name          = "backend-subnet"
  resource_group_name  = "dev-rg-ashok01"
  virtual_network_name = "todoapp_vnet"
  address_prefixes     = ["10.0.2.0/24"]
}

###Bastion Subnet
module "azurerm_bastion_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../../Modules/azurerm_subnet"
  subnet_name          = "AzureBastionSubnet"
  resource_group_name  = "dev-rg-ashok01"
  virtual_network_name = "todoapp_vnet"
  address_prefixes     = ["10.0.3.0/24"]
}

###Public IP for LB 
module "public_ip" {
  depends_on          = [module.azurerm_virtual_network]
  source              = "../../Modules/azurerm_public_ip"
  pip_name            = "frontend_pip"
  resource_group_name = "dev-rg-ashok01"
  location            = "West US"
}

###Public IP for Bastion
module "bastion_public_ip" {
  depends_on          = [module.azurerm_virtual_network]
  source              = "../../Modules/azurerm_public_ip"
  pip_name            = "bastion_pip"
  resource_group_name = "dev-rg-ashok01"
  location            = "West US"
}

#Bastion Host module
module "bastion_host" {
  depends_on           = [module.azurerm_bastion_subnet, module.bastion_public_ip]
  source               = "../../Modules/azurerm_bastion_host"
  location             = "West US"
  resource_group_name  = "dev-rg-ashok01"
  ip_conf_bastion      = "bastion-ip-config"
  subnet_name          = "AzureBastionSubnet"
  virtual_network_name = "todoapp_vnet"
  pip_name             = module.bastion_public_ip.pip_name
  bastion_name         = "todo-bastion-host"
}

##virtual Machines for Application servers
module "vm1" {
  depends_on             = [module.azurerm_frontend_subnet, module.key_vault, module.vm_password_secret, module.vm_username_secret]
  source                 = "../../Modules/azurerm_virtual_machine"
  network_interface_name = "vm1_nic"
  location               = "West US"
  resource_group_name    = "dev-rg-ashok01"
  ip_name                = "vm1_ip"
  virtual_machine_name   = "aznpfronted-vm1"
  subnet_name            = "frontend-subnet"
  virtual_network_name   = "todoapp_vnet"
  secret_username_name   = "vm-username1"
  secret_password_name   = "vm-password1"
  image_publisher        = "Canonical"
  image_offer            = "ubuntu-24_04-lts"
  image_sku              = "ubuntu-pro-gen1"
  image_version          = "latest"
  key_vault_name         = "Ashok-KV03"
  nsg_name               = "vm_lb_nsg"
}


module "vm2" {
  depends_on = [module.azurerm_backend_subnet, module.key_vault, module.vm_password_secret, module.vm_username_secret]
  source     = "../../Modules/azurerm_virtual_machine"

  network_interface_name = "vm2_nic"
  location               = "West US"
  resource_group_name    = "dev-rg-ashok01"
  ip_name                = "vm2_ip"
  virtual_machine_name   = "aznpfronted-vm2"
  subnet_name            = "frontend-subnet"
  virtual_network_name   = "todoapp_vnet"
  secret_username_name   = "vm-username1"
  secret_password_name   = "vm-password1"
  image_publisher        = "Canonical"
  image_offer            = "0001-com-ubuntu-server-focal"
  image_sku              = "20_04-lts"
  image_version          = "latest"
  key_vault_name         = "Ashok-KV03"
  nsg_name               = "vm_lb_nsg"
}


###SQL Server and Database Modules
module "sql_server" {
  depends_on           = [module.azurerm_resource_group, module.key_vault, module.vm_username_secret, module.vm_password_secret]
  source               = "../../Modules/azurerm_sql_server"
  sql_server_name      = "todosqlserver111"
  location             = "West US"
  resource_group_name  = "dev-rg-ashok01"
  key_vault_name       = "Ashok-KV03"
  secret_username_name = "vm-username1"
  secret_password_name = "vm-password1"
}

module "sql_database" {
  depends_on          = [module.sql_server]
  source              = "../../Modules/azurerm_sql_database"
  database_name       = "todoappdb"
  sql_server_name     = "todosqlserver111"
  resource_group_name = "dev-rg-ashok01"

}


####Key Vault and Secrets Modules
module "key_vault" {
  depends_on          = [module.azurerm_resource_group]
  source              = "../../Modules/azurerm_key_vault"
  key_vault_name      = "Ashok-KV03"
  location            = "West US"
  resource_group_name = "dev-rg-ashok01"
}

module "vm_username_secret" {
  depends_on          = [module.key_vault]
  source              = "../../Modules/azurerm_key_vault_secret"
  key_vault_name      = "Ashok-KV03"
  secret_name         = "vm-username1"
  secret_value        = "devopsadmin"
  resource_group_name = "dev-rg-ashok01"

}
module "vm_password_secret" {
  depends_on          = [module.key_vault, module.vm_username_secret]
  source              = "../../Modules/azurerm_key_vault_secret"
  key_vault_name      = "Ashok-KV03"
  secret_name         = "vm-password1"
  secret_value        = "V*nhel$ing$4365"
  resource_group_name = "dev-rg-ashok01"
}

##LB, Frontend IP config, Proble, Backend Pool, LB rule
module "loadBalancer" {
  depends_on              = [module.azurerm_resource_group, module.public_ip]
  source                  = "../../Modules/azurerm_loadbalancer"
  lb_name                 = "Netflix-LB"
  resource_group_name     = "dev-rg-ashok01"
  resource_group_location = "West US"
  lb_ip_conf              = "Netflix-PIP"
  lb_pool                 = "LB-Pool1"
  pip_name                = module.public_ip.pip_name
  lb_probe                = "LB-health-proble"
  lb_rule                 = "LB-heathcheck-rule"
}

#### Associate VM1 NIC with LB Backend Pool
module "lb_nic_association_vm1" {
  depends_on            = [module.vm1, module.loadBalancer]
  source                = "../../Modules/azurerm_nic_lb_association"
  nic_name              = "vm1_nic"
  lb_name               = "Netflix-LB"
  lb_pool               = "LB-Pool1"
  resource_group_name   = "dev-rg-ashok01"
  ip_configuration_name = "vm1_ip"


}

#### Associate VM2 NIC with LB Backend Pool
module "lb_nic_association_vm2" {
  depends_on            = [module.vm2, module.loadBalancer]
  source                = "../../Modules/azurerm_nic_lb_association"
  nic_name              = "vm2_nic"
  lb_name               = "Netflix-LB"
  lb_pool               = "LB-Pool1"
  resource_group_name   = "dev-rg-ashok01"
  ip_configuration_name = "vm2_ip"

}

