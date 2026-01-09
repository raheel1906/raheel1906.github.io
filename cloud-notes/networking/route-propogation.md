# Azure Route propogation - What it Really Does and usecases to Disable the feature

## What we are trying to achieve
We experianced an issue where traffic from our corporate network that was unable to reach a web application hosted on an App Service Environment that had privat endpoint, secured by a Network Security Group (NSG) and Site access rules had explicity allowed the ranges needed to access the frontend. 


## What I expected
This is a routine for the Cloud platform team, opening on-prem networks to reach private web applications hosted in Azure. It's straightforward process and usually goes like this:
**On-prem firewall** -> **ExpressRoute** -> **Azure Firewall** -> **Spoke NSG** -> **Web application**

All of the stops need to have an allow rule to make sure the traffic flows through. We made sure everything was allowed, and exptected to reach the Frontend when connected to our corporate network or VPN. **Surprisingly this did not work.**


## What actually happened
After a good 2/3 hours of troubleshooting with the developer, myself and a cloud architect we tested more or less everything that was relevant to checkout. What we missed was a small detail on the route table. 

The route table is usually vended through subscription vending, and our governance guardrails ensure that all subnets must have a route table assosiated with it (as well as a NSG).

The developers team had created a new route table, and that route table had **enabled Propogate gateway routes**.

## Why this happens (technical explanation)
Deep dive.

## How we fixed it
Exact solution.

## Lessons learned
2–4 bullets.

## References
Links to docs, etc.