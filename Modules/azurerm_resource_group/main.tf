resource "azurerm_resource_group" "RG" {
  name     = var.resource_group_name
  location = var.resource_group_location
}



# resource "azurerm_resource_group" "RG" {
#   name     = "todo_app_rg"
#   location = "West US"
# }
