# Azure Policy constraint for subnet creation: azurerm vs. azapi

## What we are trying to achieve
In our Azure cloud platform we use Azure policy to ensure that each subnet creation is forced to associate a route table and Network Security group upon creation.

Creation of a subnet with route table and network security group association is a straightforward process if you have ever done so with infrastructure as code. In my experience with Terraform, you would typically look at something like this. I will assume a resource group and Virtual network already exists. 

```hcl
# Existing Resource Group
data "azurerm_resource_group" "existing_resource_group" {
  name = var.resource_group_name
}

# Existing Virtual Network
data "azurerm_virtual_network" "existing_virtual_network" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.existing_resource_group.name
}

# Existing Network Security Group
data "azurerm_network_security_group" "existing_network_security_group" {
  name                = var.nsg_name
  resource_group_name = data.azurerm_resource_group.existing_resource_group.name
}

# Existing Route table
data "azurerm_route_table" "existing_route_table" {
  name                = var.route_table_name
  resource_group_name = data.azurerm_resource_group.existing_resource_group.name
}

# Subnet creation
resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = data.azurerm_resource_group.existing_resource_group.name
  virtual_network_name = data.azurerm_virtual_network.existing_virtual_network.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Associations
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = data.azurerm_network_security_group.existing.id
}

resource "azurerm_subnet_route_table_association" "route_association" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = data.azurerm_route_table.existing.id
}


```

## What I expected
Having done this previously with a similar approach to the one above, I was expecting this to be a straight forward process. 

## What actually happened
Since we leverage CI/CD actions workflow, I observed a failed CD pipeline with an error code that basically explained that Azure Policy was complaining about the subnet creation being in conflict with the Azure policy that ensures route table and Network Security Group is associated with the subnet upon creation. 

So, in short, our platform guardrails were stopping me from creating the subnet even with the necessary associations. 

## Why this happens
After some digging, it became clearer that even though azurerm is the stable and well-tested layer on top of Azure APIs, there are definitely some scenarios where this is not a good fit.

My observations were that the azurerm provider does API calls in sequence, something like this:
1. Create subnet
2. Associate Route Table to subnet
3. Associate Network Security Group to subnet

This is the core of the issue: Azure registers a subnet creation in itself without the conditions of the Azure Policy being met (route table and NSG association). 

## How we fixed it
The approach was switched to leverage the AzApi provider. AzApi is a lightweight wrapper around Azure APIs, and operations can occur simultaneously compared to azurerm. The code that ended up landing me a subnet without making Azure policy angry is presented below.

```hcl
resource "azapi_resource" "subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-07-01"
  name      = var.private_endpoints_subnet_name
  parent_id = var.virtual_network_id
  locks     = [var.virtual_network_id] 

  body = {
    properties = {
      addressPrefix = var.private_endpoints_subnet_range

      privateEndpointNetworkPolicies    = "Disabled"
      privateLinkServiceNetworkPolicies = "Enabled"
      networkSecurityGroup = {
        id = var.default_nsg_id
      }
      routeTable = {
        id = var.route_table_id
      }
    }
  }
}
```
## Lessons learned
While azurerm is a stable and easier-to-use provider, there are definitely scenarios where one needs to evaluate a switch to the AzApi provider to ensure a compliant deployment of infrastructure in the Azure cloud environment.

## References
https://www.hashicorp.com/en/blog/enhancing-azure-deployments-with-azurerm-and-azapi-terraform-providers
https://github.com/hashicorp/terraform-provider-azurerm/issues/9022
https://registry.terraform.io/modules/haflidif/alz-subnet/azurerm/latest