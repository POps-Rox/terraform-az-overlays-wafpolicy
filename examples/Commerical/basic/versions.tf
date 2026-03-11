# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.36"
    }
  }
}

provider "azurerm" {
  environment = var.environment
  features {}
  skip_provider_registration = true
}
