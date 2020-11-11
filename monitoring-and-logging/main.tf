provider "azurerm" {
  version = "~> 2.30"
  features {}
}

variable "resource_group_name" {
  default = "pluralsight"
}

variable "location" {
  default = "eastus"
}

resource "random_string" "application_name" {
  length = 24
  upper = false
  lower = true
  number = false
  special = false
}

resource "azurerm_storage_account" "application" {
  name                = random_string.application_name.result
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  access_tier               = "Hot"
  account_replication_type  = "LRS"
  allow_blob_public_access  = true
}

resource "azurerm_storage_container" "releases" {
    name                  = "releases"
    storage_account_name  = azurerm_storage_account.application.name
    container_access_type = "container"
}

resource "azurerm_storage_blob" "latest" {
  name                   = "latest.zip"
  storage_account_name   = azurerm_storage_account.application.name
  storage_container_name = azurerm_storage_container.releases.name
  type                   = "Block"
  source                 = "./latest.zip"
}

resource "azurerm_app_service_plan" "application" {
  name                = random_string.application_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "application" {
  name                        = random_string.application_name.result
  location                    = var.location
  resource_group_name         = var.resource_group_name
  app_service_plan_id         = azurerm_app_service_plan.application.id
  storage_account_name        = azurerm_storage_account.application.name
  storage_account_access_key  = azurerm_storage_account.application.primary_access_key
  version                     = "~3"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
    "HASH"                     = base64encode(filesha256("./latest.zip"))
    "WEBSITE_RUN_FROM_PACKAGE" = "${azurerm_storage_account.application.primary_blob_endpoint}${azurerm_storage_container.releases.name}/${azurerm_storage_blob.latest.name}"
  }
}
