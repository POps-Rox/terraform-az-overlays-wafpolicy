<!-- BADGES:START -->
[![CI](https://github.com/POps-Rox/tf-az-overlays-wafpolicy/actions/workflows/ci.yml/badge.svg)](https://github.com/POps-Rox/tf-az-overlays-wafpolicy/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/POps-Rox/tf-az-overlays-wafpolicy/pulls)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/POps-Rox/tf-az-overlays-wafpolicy/graphs/commit-activity)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4.svg?logo=terraform)](https://www.terraform.io)
<!-- BADGES:END -->

# Azure WAF Policy Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/azurenoops/overlays-waf-policy/azurerm/)

This Overlay terraform module creates an [Azure WAF policy](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/policy-overview) with OWASP 3.2 enabled to be used in a [SCCA compliant Management Network](https://registry.terraform.io/modules/azurenoops/overlays-management-spoke/azurerm/latest).

## Using Azure Clouds

Since this module is built for both public and us government clouds. The `environment` variable defaults to `public` for Azure Cloud. When using this module with the Azure Government Cloud, you must set the `environment` variable to `usgovernment`. You will also need to set the azurerm provider `environment` variable to the proper cloud as well. This will ensure that the correct Azure Government Cloud endpoints are used. You will also need to set the `location` variable to a valid Azure Government Cloud location.

Example Usage for Azure Government Cloud:

```hcl

provider "azurerm" {
  environment = "usgovernment"
}

module "overlays-waf-policy" {
  source  = "POps-Rox/tf-az-overlays-waf-policy/azurerm"
  version = "x.x.x"
  
  location = "usgovvirginia"
  environment = "usgovernment"
  ...
}

```

### Resource Provider List

Terraform requires the following resource providers to be available:

- Microsoft.Network
- Microsoft.Storage
- Microsoft.Compute
- Microsoft.KeyVault
- Microsoft.Authorization
- Microsoft.Resources
- Microsoft.OperationalInsights
- Microsoft.GuestConfiguration
- Microsoft.Insights
- Microsoft.Advisor
- Microsoft.Security
- Microsoft.OperationsManagement
- Microsoft.AAD
- Microsoft.AlertsManagement
- Microsoft.Authorization
- Microsoft.AnalysisServices
- Microsoft.Automation
- Microsoft.Subscription
- Microsoft.Support
- Microsoft.PolicyInsights
- Microsoft.SecurityInsights
- Microsoft.Security
- Microsoft.Monitor
- Microsoft.Management
- Microsoft.ManagedServices
- Microsoft.ManagedIdentity
- Microsoft.Billing
- Microsoft.Consumption

Please note that some of the resource providers may not be available in Azure Government Cloud. Please check the [Azure Government Cloud documentation](https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-cli) for more information.

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation]("https://www.cisa.gov/secure-cloud-computing-architecture").

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Resources Supported

* [Azure WAF Policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy)

## Module Usage

```terraform
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "overlays-waf-policy" {
  source  = "POps-Rox/tf-az-overlays-waf-policy/azurerm"
  version = "x.x.x"
  
  create_waf_resource_group = true
  location                  = "eastus"
  deploy_environment        = "dev"
  org_name                  = "anoa"
  environment               = "public"
  workload_name             = "waf"

  policy_mode = "Detection"

  managed_rule_set_configuration = [
    {
      type    = "OWASP"
      version = "3.2"
    }
  ]

  custom_rules_configuration = [
    {
      name      = "DenyAll"
      priority  = 1
      rule_type = "MatchRule"
      action    = "Block"

      match_conditions_configuration = [
        {
          match_variable_configuration = [
            {
              variable_name = "RemoteAddr"
              selector      = null
            }
          ]

          match_values = [
            "X.X.X.X"
          ]

          operator           = "IPMatch"
          negation_condition = true
          transforms         = null
        },
        {
          match_variable_configuration = [
            {
              variable_name = "RequestUri"
              selector      = null
            },
            {
              variable_name = "RequestUri"
              selector      = null
            }
          ]

          match_values = [
            "Azure",
            "Cloud"
          ]

          operator           = "Contains"
          negation_condition = true
          transforms         = null
        }
      ]
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurenoopsutils"></a> [azurenoopsutils](#requirement\_azurenoopsutils) | ~> 1.0.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurenoopsutils"></a> [azurenoopsutils](#provider\_azurenoopsutils) | ~> 1.0.4 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mod_azregions"></a> [mod\_azregions](#module\_mod\_azregions) | azurenoops/overlays-azregions-lookup/azurerm | >= 1.0.0 |
| <a name="module_mod_scaffold_rg"></a> [mod\_scaffold\_rg](#module\_mod\_scaffold\_rg) | azurenoops/overlays-resource-group/azurerm | >= 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_web_application_firewall_policy.waf_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |
| [azurenoopsutils_resource_name.vnet](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurerm_resource_group.rgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_tags"></a> [add\_tags](#input\_add\_tags) | Map of custom tags. | `map(string)` | `{}` | no |
| <a name="input_create_private_endpoint_subnet"></a> [create\_private\_endpoint\_subnet](#input\_create\_private\_endpoint\_subnet) | Controls if the subnet should be created. If set to false, the subnet name must be provided. Default is false. | `bool` | `false` | no |
| <a name="input_create_waf_resource_group"></a> [create\_waf\_resource\_group](#input\_create\_waf\_resource\_group) | Controls if the resource group should be created. If set to false, the resource group name must be provided. Default is false. | `bool` | `false` | no |
| <a name="input_custom_rules_configuration"></a> [custom\_rules\_configuration](#input\_custom\_rules\_configuration) | Custom rules configuration object with following attributes:<pre>- name:                           Gets name of the resource that is unique within a policy. This name can be used to access the resource.<br>- priority:                       Describes priority of the rule. Rules with a lower value will be evaluated before rules with a higher value.<br>- rule_type:                      Describes the type of rule. Possible values are `MatchRule` and `Invalid`.<br>- action:                         Type of action. Possible values are `Allow`, `Block` and `Log`.<br>- match_conditions_configuration: One or more `match_conditions` blocks as defined below.<br>- match_variable_configuration:   One or more match_variables blocks as defined below.<br>- variable_name:                  The name of the Match Variable. Possible values are RemoteAddr, RequestMethod, QueryString, PostArgs, RequestUri, RequestHeaders, RequestBody and RequestCookies.<br>- selector:                       Describes field of the matchVariable collection<br>- match_values:                   A list of match values.<br>- operator:                       Describes operator to be matched. Possible values are IPMatch, GeoMatch, Equal, Contains, LessThan, GreaterThan, LessThanOrEqual, GreaterThanOrEqual, BeginsWith, EndsWith and Regex.<br>- negation_condition:             Describes if this is negate condition or not<br>- transforms:                     A list of transformations to do before the match is attempted. Possible values are HtmlEntityDecode, Lowercase, RemoveNulls, Trim, UrlDecode and UrlEncode.</pre> | <pre>list(object({<br>    name      = optional(string)<br>    priority  = optional(number)<br>    rule_type = optional(string)<br>    action    = optional(string)<br>    match_conditions_configuration = optional(list(object({<br>      match_variable_configuration = optional(list(object({<br>        variable_name = optional(string)<br>        selector      = optional(string, null)<br>      })))<br>      match_values       = optional(list(string))<br>      operator           = optional(string)<br>      negation_condition = optional(string, null)<br>      transforms         = optional(list(string), null)<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_custom_waf_resource_group_name"></a> [custom\_waf\_resource\_group\_name](#input\_custom\_waf\_resource\_group\_name) | The name of the custom resource group to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_default_tags_enabled"></a> [default\_tags\_enabled](#input\_default\_tags\_enabled) | Option to enable or disable default tags. | `bool` | `true` | no |
| <a name="input_deploy_environment"></a> [deploy\_environment](#input\_deploy\_environment) | Name of the workload's environnement | `string` | n/a | yes |
| <a name="input_disable_telemetry"></a> [disable\_telemetry](#input\_disable\_telemetry) | If set to true, will disable the telemetry sent as part of the module. | `string` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Manages a Private Endpoint to Azure Container Registry. Default is false. | `bool` | `false` | no |
| <a name="input_enable_resource_locks"></a> [enable\_resource\_locks](#input\_enable\_resource\_locks) | (Optional) Enable resource locks, default is false. If true, resource locks will be created for the resource group and the storage account. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The Terraform backend environment e.g. public or usgovernment | `string` | n/a | yes |
| <a name="input_exclusion_configuration"></a> [exclusion\_configuration](#input\_exclusion\_configuration) | Exclusion rules configuration object with following attributes:<pre>- match_variable:          The name of the Match Variable. Accepted values can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#match_variable<br>- selector:                Describes field of the matchVariable collection.<br>- selector_match_operator: Describes operator to be matched. Possible values: `Contains`, `EndsWith`, `Equals`, `EqualsAny`, `StartsWith`.<br>- excluded_rule_set:       One or more `excluded_rule_set` block defined below.<br>- type:                    The rule set type. The only possible value is `OWASP` . Defaults to `OWASP`.<br>- version:                 The rule set version. The only possible value is `3.2` . Defaults to `3.2`.<br>- rule_group:              One or more `rule_group` block defined below.<br>- rule_group_name:         The name of rule group for exclusion. Accepted values can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#rule_group_name<br>- excluded_rules:          One or more Rule IDs for exclusion.</pre> | <pre>list(object({<br>    match_variable          = optional(string)<br>    selector                = optional(string)<br>    selector_match_operator = optional(string)<br>    excluded_rule_set = optional(list(object({<br>      type    = optional(string, "OWASP")<br>      version = optional(string, "3.2")<br>      rule_group = optional(list(object({<br>        rule_group_name = optional(string)<br>        excluded_rules  = optional(string)<br>      })))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_existing_private_dns_zone"></a> [existing\_private\_dns\_zone](#input\_existing\_private\_dns\_zone) | Name of the existing private DNS zone | `any` | `null` | no |
| <a name="input_existing_private_subnet_name"></a> [existing\_private\_subnet\_name](#input\_existing\_private\_subnet\_name) | Name of the existing subnet for the private endpoint | `any` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of the existing resource group to use. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_hub_firewall_private_ip_address"></a> [hub\_firewall\_private\_ip\_address](#input\_hub\_firewall\_private\_ip\_address) | The private IP of the hub virtual network firewall | `any` | `null` | no |
| <a name="input_hub_resource_group_name"></a> [hub\_resource\_group\_name](#input\_hub\_resource\_group\_name) | The name of hub resource group | `any` | `null` | no |
| <a name="input_hub_virtual_network_name"></a> [hub\_virtual\_network\_name](#input\_hub\_virtual\_network\_name) | The name of hub virutal network | `any` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which instance will be hosted | `string` | n/a | yes |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | (Optional) id locks are enabled, Specifies the Level to be used for this Lock. | `string` | `"CanNotDelete"` | no |
| <a name="input_log_analytics_customer_id"></a> [log\_analytics\_customer\_id](#input\_log\_analytics\_customer\_id) | The Workspace (or Customer) ID for the Log Analytics Workspace. | `string` | `""` | no |
| <a name="input_log_analytics_logs_retention_in_days"></a> [log\_analytics\_logs\_retention\_in\_days](#input\_log\_analytics\_logs\_retention\_in\_days) | The log analytics workspace data retention in days. Possible values range between 30 and 730. | `string` | `""` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Specifies the id of the Log Analytics Workspace | `string` | `""` | no |
| <a name="input_managed_rule_set_configuration"></a> [managed\_rule\_set\_configuration](#input\_managed\_rule\_set\_configuration) | Managed rule set configuration. | <pre>list(object({<br>    type    = optional(string, "OWASP")<br>    version = optional(string, "3.2")<br>    rule_group_override_configuration = optional(list(object({<br>      rule_group_name = optional(string, null)<br>      rule = optional(list(object({<br>        id      = string<br>        enabled = optional(bool)<br>        action  = optional(string)<br>      })), [])<br>    })))<br><br>  }))</pre> | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional prefix for the generated name | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix for the generated name | `string` | `""` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Name of the organization | `string` | n/a | yes |
| <a name="input_policy_enabled"></a> [policy\_enabled](#input\_policy\_enabled) | Describes if the policy is in `enabled` state or `disabled` state. Defaults to `true`. | `string` | `true` | no |
| <a name="input_policy_file_limit"></a> [policy\_file\_limit](#input\_policy\_file\_limit) | Policy regarding the size limit of uploaded files. Value is in MB. Accepted values are in the range `1` to `4000`. Defaults to `100`. | `number` | `100` | no |
| <a name="input_policy_max_body_size"></a> [policy\_max\_body\_size](#input\_policy\_max\_body\_size) | Policy regarding the maximum request body size. Value is in KB. Accepted values are in the range `8` to `2000`. Defaults to `128`. | `number` | `128` | no |
| <a name="input_policy_mode"></a> [policy\_mode](#input\_policy\_mode) | Describes if it is in detection mode or prevention mode at the policy level. Valid values are `Detection` and `Prevention`. Defaults to `Prevention`. | `string` | `"Prevention"` | no |
| <a name="input_policy_request_body_check_enabled"></a> [policy\_request\_body\_check\_enabled](#input\_policy\_request\_body\_check\_enabled) | Describes if the Request Body Inspection is enabled. Defaults to `true`. | `string` | `true` | no |
| <a name="input_private_subnet_address_prefix"></a> [private\_subnet\_address\_prefix](#input\_private\_subnet\_address\_prefix) | The name of the subnet for private endpoints | `any` | `null` | no |
| <a name="input_use_location_short_name"></a> [use\_location\_short\_name](#input\_use\_location\_short\_name) | Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored. | `bool` | `true` | no |
| <a name="input_use_naming"></a> [use\_naming](#input\_use\_naming) | Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network for the private endpoint | `any` | `null` | no |
| <a name="input_waf_policy_custom_name"></a> [waf\_policy\_custom\_name](#input\_waf\_policy\_custom\_name) | Custom WAF Policy name, generated if not set. | `string` | `""` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Name of the workload\_name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_listener_ids"></a> [http\_listener\_ids](#output\_http\_listener\_ids) | A list of HTTP Listener IDs from an azurerm\_application\_gateway. |
| <a name="output_path_based_rule_ids"></a> [path\_based\_rule\_ids](#output\_path\_based\_rule\_ids) | A list of URL Path Map Path Rule IDs from an azurerm\_application\_gateway. |
| <a name="output_waf_policy_id"></a> [waf\_policy\_id](#output\_waf\_policy\_id) | Waf Policy ID |
<!-- END_TF_DOCS -->