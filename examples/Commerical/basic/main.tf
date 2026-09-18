# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_waf_policy" {
  #source  = "github.com/POps-Rox/terraform-az-overlays-wafpolicy"
  #version = "~> x.x.x"
  source = "../../.."

  providers = {
    azurerm             = azurerm
    azurerm.hub_network = azurerm.hub_network
  }

  # By default, this module will create a resource group, provide the name here
  # To use an existing resource group, specify the existing resource group name, 
  # and set the argument to `create_waf_resource_group = false`. Location will be same as existing RG.
  create_waf_resource_group = true
  location                  = var.default_location
  deploy_environment        = var.deploy_environment
  org_name                  = var.org_name
  environment               = var.environment
  workload_name             = "waf"
}
