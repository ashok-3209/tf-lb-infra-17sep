data "azurerm_public_ip" "lb_publicIP" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = var.lb_ip_conf
    public_ip_address_id = data.azurerm_public_ip.lb_publicIP.id
  }
}


resource "azurerm_lb_backend_address_pool" "pool1" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = var.lb_pool
}



resource "azurerm_lb_probe" "example" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = var.lb_probe
  port            = 22
}

resource "azurerm_lb_rule" "lbrule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = var.lb_rule
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name 
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.pool1.id ]
  probe_id = azurerm_lb_probe.example.id
}

