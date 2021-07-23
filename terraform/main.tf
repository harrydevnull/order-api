terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 2.26"
        }
    }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name = "${var.project}-${var.environment}-resource-group"
  location = var.location
}


resource "azurerm_storage_account" "storage_account" {
    name = "${var.project}${var.environment}storage"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"

}

resource "azurerm_application_insights" "application_insights" {

    name = "${var.project}-${var.environment}-application-insights"
    location= var.location
    resource_group_name = azurerm_resource_group.resource_group.name
    application_type = "web"
}

resource "azurerm_app_service_plan" "app_service_plan" {

    name  = "${var.project}-${var.environment}-app-service-plan"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = var.location
    kind = "FunctionApp"
    reserved = true
    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

resource "azurerm_function_app" "function_app" {
  
   name                       = "${var.project}-${var.environment}-function-app"
   resource_group_name        = azurerm_resource_group.resource_group.name
   location                   = var.location
   app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id

    storage_account_name       = azurerm_storage_account.storage_account.name
    storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
    https_only                 = true
    os_type                    = "linux"
    version                    = "~3"

    app_settings = {
        "FUNCTIONS_WORKER_RUNTIME" = "custom"
        "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key
    }
}
