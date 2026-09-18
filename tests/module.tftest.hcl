mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      name     = "existing-rg"
      location = "westus2"
    }
  }
}

mock_provider "azurerm" {
  alias = "hub_network"
}

mock_provider "azapi" {}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "Generated-WAFP-Name"
    }
  }
}

variables {
  location           = "eastus"
  environment        = "public"
  deploy_environment = "test"
  workload_name      = "payments"
  org_name           = "contoso"
}

run "existing_resource_group_default_policy" {
  command = plan

  variables {
    create_waf_resource_group    = false
    existing_resource_group_name = "existing-rg"
    waf_policy_custom_name       = ""
    add_tags = {
      owner = "platform"
      env   = "override"
    }
  }

  override_module {
    target = module.mod_azregions
    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  assert {
    condition     = length(data.azurerm_resource_group.rgrp) == 1
    error_message = "Existing resource group lookup must be enabled when create_waf_resource_group is false."
  }

  assert {
    condition     = length(module.mod_scaffold_rg) == 0
    error_message = "Resource group module must be disabled when create_waf_resource_group is false."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.name == "generated-wafp-name"
    error_message = "Empty waf_policy_custom_name must fall through to the generated name."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.location == "westus2"
    error_message = "Policy location must pass through from the existing resource group."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.resource_group_name == "existing-rg"
    error_message = "Policy resource group name must pass through from the existing resource group."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.tags.deployedBy == "AzureNoOpsTF [default]" && azurerm_web_application_firewall_policy.waf_policy.tags.env == "override" && azurerm_web_application_firewall_policy.waf_policy.tags.workload == "payments" && azurerm_web_application_firewall_policy.waf_policy.tags.owner == "platform" && length(azurerm_web_application_firewall_policy.waf_policy.tags) == 4
    error_message = "Policy tags must merge default tags with add_tags, allowing add_tags to override duplicates."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.policy_settings[0].mode == "Prevention"
    error_message = "Default policy mode must remain Prevention."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.managed_rules[0].managed_rule_set[0].type == "OWASP" && azurerm_web_application_firewall_policy.waf_policy.managed_rules[0].managed_rule_set[0].version == "3.2"
    error_message = "Default managed rules must render the required OWASP rule set."
  }
}

run "created_resource_group_custom_policy" {
  command = plan

  variables {
    create_waf_resource_group         = true
    custom_waf_resource_group_name    = "custom-rg"
    waf_policy_custom_name            = "custom-waf-policy"
    policy_mode                       = "Detection"
    policy_enabled                    = true
    policy_request_body_check_enabled = true
    managed_rule_set_configuration = [
      {
        type    = "OWASP"
        version = "3.2"
        rule_group_override_configuration = [
          {
            rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
            rule = [
              {
                id      = "942100"
                enabled = false
                action  = "Log"
              }
            ]
          }
        ]
      }
    ]
    exclusion_configuration = [
      {
        match_variable          = "RequestHeaderNames"
        selector                = "x-skip"
        selector_match_operator = "Equals"
        excluded_rule_set = [
          {
            type    = "OWASP"
            version = "3.2"
            rule_group = [
              {
                rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
                excluded_rules  = "930100"
              }
            ]
          }
        ]
      }
    ]
    custom_rules_configuration = [
      {
        name      = "BlockBadIp"
        priority  = 10
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
            match_values       = ["10.0.0.1"]
            operator           = "IPMatch"
            negation_condition = false
            transforms         = null
          }
        ]
      }
    ]
  }

  override_module {
    target = module.mod_azregions
    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  override_module {
    target = module.mod_scaffold_rg[0]
    outputs = {
      resource_group_name     = "custom-rg"
      resource_group_location = "eastus"
    }
  }

  assert {
    condition     = length(data.azurerm_resource_group.rgrp) == 0
    error_message = "Existing resource group lookup must be disabled when create_waf_resource_group is true."
  }

  assert {
    condition     = length(module.mod_scaffold_rg) == 1
    error_message = "Resource group module must be enabled when create_waf_resource_group is true."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.name == "custom-waf-policy"
    error_message = "Custom WAF policy name must override generated naming."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.location == "eastus"
    error_message = "Created resource group location must pass through to the policy."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.resource_group_name == "custom-rg"
    error_message = "Created resource group name must pass through to the policy."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.policy_settings[0].mode == "Detection"
    error_message = "Policy mode variable must drive policy_settings.mode."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.managed_rules[0].managed_rule_set[0].rule_group_override[0].rule[0].action == "Log"
    error_message = "Managed rule override action must be rendered into the WAF policy."
  }

  assert {
    condition     = contains(azurerm_web_application_firewall_policy.waf_policy.managed_rules[0].exclusion[0].excluded_rule_set[0].rule_group[0].excluded_rules, "930100") && length(azurerm_web_application_firewall_policy.waf_policy.managed_rules[0].exclusion[0].excluded_rule_set[0].rule_group[0].excluded_rules) == 1
    error_message = "Exclusion rule IDs must be rendered into the WAF policy."
  }

  assert {
    condition     = azurerm_web_application_firewall_policy.waf_policy.custom_rules[0].match_conditions[0].match_variables[0].variable_name == "RemoteAddr"
    error_message = "Custom rule match variables must be rendered into the WAF policy."
  }
}
