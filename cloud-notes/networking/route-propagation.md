# Azure Route Propagation: Why It Broke ASE but Not App Service

## What we are trying to achieve
We experianced an issue where traffic from our corporate network that was unable to reach a web application hosted on an App Service Environment that had privat endpoint, secured by a Network Security Group (NSG) and Site access rules had explicity allowed the ranges needed to access the frontend. 


## What I expected
This is a routine for the Cloud platform team, opening on-prem networks to reach private web applications hosted in Azure. It's straightforward process and usually goes like this:
**On-prem firewall** -> **ExpressRoute** -> **Azure Firewall** -> **Spoke NSG** -> **Web application**

All of the stops need to have an allow rule to make sure the traffic flows through. We made sure everything was allowed, and exptected to reach the Frontend when connected to our corporate network or VPN. **Surprisingly this did not work.**


## What actually happened
After 2–3 hours of troubleshooting together with the developer and a cloud architect, we had validated most of the obvious candidates (DNS, NSGs, firewall rules on-prem, firewall rules cloud, private endpoint / ASE config, etc.).

Root cause turned out to be a small, but critical detail in the route table configuration.

The route table is vended through subscription vending, and has **route propagation Disabled**, because the standard design is that all outbound traffic should be forced through the hub firewall using a default route (0.0.0.0/0 → Azure Firewall). Developers usually re-use this on their subnets.

This works fine for 99% of the workloads in out environment, and there were several examples were similar setup was already working, for example for Workload A (app service).

For Workload B (ASE), on-prem clients could not reach the web frontend until we enabled route propagation on the relevant subnet route table.


## Why this happens
The observations are as follows, the difference is not in the networking topology — it is in how the services themselves integrate with the VNet.

App Service is not deployed into the Virtual Network, the private endpoints is a logical resource representing a network endpoint for the service, ASE on the other hand is deployed into the Virtual Network. From a routing perspective it behaves like compute behind an internal load balancer. This gives an impression that its fully subject to UDRs and BGP propagation settings.

Disabling route propagation is correct setup for this scenario on App Service + Private Endpoint, but can break connectivity for ASE because it removes the dynamically learned on-prem routes from the subnet that actually needs them to return traffic correctly.

## How we fixed it
Enabling route propagation on the ASE subnet’s route table allowed the subnet to learn the on-prem prefixes via BGP again, which restored a symmetric path and immediately resolved the issue.

## Lessons learned
- Not all PaaS services behave the same from a networking perspective
Even if two very similar services are trying to achieve the same outcome, their fundamental networking models need to be assessed accordingly to find the correct solution.

- Route propagation settings matter for different PaaS services
Disabling BGP route propagation is a common and often correct baseline for spoke subnets, but it is not universally applicable. Services like ASE that live inside the VNet may require dynamically learned routes to function correctly, especially for return traffic to on-premises.

- Identical networking does not mean identical traffic behavior
Two spokes can be architecturally identical and still behave differently depending on what workloads are deployed into them.

- Involve a second pair of eyes, and communicate your observations clearly
Troubleshooting and understanding a technical issue alone can be overwhelming. To make it clear for yourself and others, you need to practice explaining the challenge at different technical levels. This can help the issue become clearer even for yourself. Bringing in a new set of eyes can positively impact the troubleshooting, and knowledge can be more easily shared.
## References
https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview
https://learn.microsoft.com/en-us/azure/app-service/environment/networking
https://learn.microsoft.com/en-us/answers/questions/1282209/propagated-gateway-routes
https://learn.microsoft.com/en-us/answers/questions/1373116/propagate-gateway-routes-azure