# Group creation
resource "azuread_group" "group" {
  display_name     = var.group_name
  owners           = var.owners
  security_enabled = true
}

# Management Policy creation
resource "azurerm_role_management_policy" "management_policy" {
  scope              = var.subscription_id
  role_definition_id = var.role_definition_id

  eligible_assignment_rules {
    expiration_required = false
  }
}

# Role assignement creation
resource "azurerm_pim_eligible_role_assignment" "pim_additional_role_assignment" {
  scope              = var.subscription_id
  role_definition_id = var.role_definition_id
  principal_id       = var.principal_id
  depends_on         = [azurerm_role_management_policy.management_policy] # ensures assignement is compliant with new management policy
}
