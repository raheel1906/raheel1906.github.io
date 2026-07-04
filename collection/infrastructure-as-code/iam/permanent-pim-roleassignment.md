# Permanent PIM Eligible Role assignment with Infrastructure as Code

## Introduction
This article will go over how to enable a PIM role assignment permanently without any expiration date for Azure resources with Terraform.

### What I was trying to achieve
While improving our security posture, we were switching from permanent normal role assignments to PIM eligible role assignments for our Entra ID groups. While enabling PIM on these, we ran into a constraint on the maximum eligible assignment duration: Microsoft does not allow more than 365 days, so we couldn't set the assignment to have no expiration date. Our goal was to keep administrative overhead low and keep the PIM eligibility permanent on the assigned groups.

### Prerequisites

| Requirement | Details |
| --- | --- |
| Licensing | Entra ID P2 / Governance |
| Entra ID roles | Graph permissions: `Group.Read.All`, `Group.Create.All` (if also creating groups), `User.Read.All` |
| Azure RBAC | Owner at the resource group, subscription, or management group level for the identity running Terraform |
| Terraform provider version | `azurerm` 4.79.0 or later |

## Understanding the components

### Active vs. Eligible

An active assignment means the user has the role right now and can use it without any activation step. This is what a normal `azurerm_role_assignment` grants, and also what `azurerm_pim_active_role_assignment` gives but under PIM governance.

An eligible assignment means the user is allowed to hold the role but does not have it until they explicitly activate it in PIM, also known as the just-in-time (JIT) model. This is what my scenario covers, with `azurerm_pim_eligible_role_assignment`.

### Role Management policy
A crucial component to understand is the Role Management Policy, this ruleset governs how an eligible assignment or activation behaves - Like azure policy, but spesifically for this. This policy handles multiple controls, one of which **elgibility expiration**. This is set at RG, Subscription or Management group level and covers all assignments under the respective scope.

## Key observations
- Mention Provider version constraint
- Mention without role management policy you will hit the existing role management constraint, for my usecase it was 365 days
- Azure resources and not entra ID

## Terraform automation
```hcl
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
    expiration_required = false # Ensures expiration is not required in role assignment
  }
}

# Role assignement creation
resource "azurerm_pim_eligible_role_assignment" "pim_role_assignment" {
  scope              = var.subscription_id
  role_definition_id = var.role_definition_id
  principal_id       = var.principal_id
  depends_on         = [azurerm_role_management_policy.management_policy] # ensures assignement is compliant with new management policy
}

```