module "azurerm_resource_group" {
  source                  = "../Modules/azurerm_resource_group"
  resource_group_name     = "prod-todo-rg"
  resource_group_location = "West US"
}

module "azurerm_virtual_network" {
  depends_on           = [module.azurerm_resource_group]
  source               = "../Modules/azurerm_virtual_network"
  virtual_network_name = "todoapp_vnet"
  address_space        = ["10.0.0.0/16"]
  location             = "West US"
  resource_group_name  = "prod-todo-rg"
}

module "azurerm_frontend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../Modules/azurerm_subnet"
  subnet_name          = "frontend-subnet"
  resource_group_name  = "prod-todo-rg"
  virtual_network_name = "todoapp_vnet"
  address_prefixes     = ["10.0.1.0/24"]

}

module "azurerm_backend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../Modules/azurerm_subnet"
  subnet_name          = "backend-subnet"
  resource_group_name  = "prod-todo-rg"
  virtual_network_name = "todoapp_vnet"
  address_prefixes     = ["10.0.2.0/24"]
}

module "frontend_public_ip" {
  depends_on          = [module.azurerm_virtual_network]
  source              = "../Modules/azurerm_public_ip"
  pip_name            = "frontend_pip"
  resource_group_name = "prod-todo-rg"
  location            = "West US"
}

module "backend_public_ip" {
  depends_on          = [module.azurerm_virtual_network]
  source              = "../Modules/azurerm_public_ip"
  pip_name            = "backend_pip"
  resource_group_name = "prod-todo-rg"
  location            = "West US"
}



module "frontend_vm" {
  depends_on             = [module.azurerm_frontend_subnet, module.frontend_public_ip, module.key_vault, module.vm_password_secret, module.vm_username_secret]
  source                 = "../Modules/azurerm_virtual_machine"
  network_interface_name = "frontend_nic"
  location               = "West US"
  resource_group_name    = "prod-todo-rg"
  ip_name                = "frontend_ip"
  virtual_machine_name   = "todoFrontendVM"
  subnet_name          = "frontend-subnet"
  virtual_network_name = "todoapp_vnet"
  public_ip_name       = "frontend_pip"
secret_username_name = "vm-username"
    secret_password_name = "vm-password"
  image_publisher = "Canonical"
  image_offer     = "ubuntu-24_04-lts"
  image_sku       = "ubuntu-pro-gen1"
  image_version   = "latest"
  key_vault_name  = "todoappKV"
}


module "backend_vm" {
  depends_on = [module.azurerm_backend_subnet, module.backend_public_ip, module.key_vault, module.vm_password_secret, module.vm_username_secret]
  source     = "../Modules/azurerm_virtual_machine"

  network_interface_name = "backend_nic"
  location               = "West US"
  resource_group_name    = "prod-todo-rg"
  ip_name                = "backend_ip"
  virtual_machine_name   = "todoBackendVM"
  subnet_name            = "backend-subnet"
  virtual_network_name   = "todoapp_vnet"
  public_ip_name         = "backend_pip"
    secret_username_name = "vm-username"
    secret_password_name = "vm-password"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"
  image_version   = "latest"
  key_vault_name  = "todoappKV"
}

module "sql_server" {
  depends_on          = [module.azurerm_resource_group, module.key_vault, module.vm_username_secret, module.vm_password_secret]
  source              = "../Modules/azurerm_sql_server"
  sql_server_name     = "todosqlserver111"
  location            = "West US"
  resource_group_name = "prod-todo-rg"
  key_vault_name      = "todoappKV"
    secret_username_name = "vm-username"
    secret_password_name = "vm-password"
 }

module "sql_database" {
  depends_on          = [module.sql_server]
  source              = "../Modules/azurerm_sql_database"
  database_name       = "todoappdb"
  sql_server_name     = "todosqlserver111"
  resource_group_name = "prod-todo-rg"

}


module "key_vault" {
  depends_on          = [module.azurerm_resource_group]
  source              = "../Modules/azurerm_key_vault"
  key_vault_name      = "todoappKV"
  location            = "West US"
  resource_group_name = "prod-todo-rg"
}

module "vm_username_secret" {
  depends_on          = [module.key_vault]
  source              = "../Modules/azurerm_key_vault_secret"
  key_vault_name      = "todoappKV"
  secret_name         = "vm-username"
  secret_value        = "dummyuser"
  resource_group_name = "prod-todo-rg"

}
module "vm_password_secret" {
  depends_on          = [module.key_vault, module.vm_username_secret]
  source              = "../Modules/azurerm_key_vault_secret"
  key_vault_name      = "todoappKV"
  secret_name         = "vm-password"
  secret_value        = "Dummy@12345"
  resource_group_name = "prod-todo-rg"
}

