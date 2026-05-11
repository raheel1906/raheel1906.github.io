# Service Enablement Framework - Part of the Cloud Adoption Framework

## Problem
In enterprise environments, allowing teams to freely deploy services from the Azure Marketplace or new services can create challenges.

- Lack of governance and control
- Inconsistent configuration
- Security and compliance risks
- Difficulty maintaining standardization across Landing Zones

At the same time, being too strict can slow down and even block innovation for application teams. 
Then you might ask yourself, ***how do you allow teams to use Azure services without losing control?***

## What is the Service Enablement Framework?
The Service Enablement Framework is part of the Cloud Adoption Framework (CAF), and targets a very specific scenario. It's essentially a structured approach to the problem described above and aims towards:

- Control what services can be used
- Define how they should be deployed
- Ensure they comply with platform and organisational standards
- Document the release into the platform

The shift becomes more clear by stating ***"Teams can deploy approved services, in an approved way"*** instead of ***"Teams can deploy anything"***.

Compared to other parts of CAF this is not heavily documented, as of now you will only find about 60 questions that are used to assess a service (see References).

The main topics are:
- Security
- Identity and Access Management
- Governance
- Operations
- Azure Service Compliance

## How to approach it
First and foremost, you need to start with some core services that build the foundation of your landing zone and also identify frequently used services that are a genuine need from the application teams. 

This approach should accelerate the process, and have you working against something tangible quickly.  

## How it works in practice

### Explore the service
An Engineer should understand core functionality of the service. Deploy it, understand identity and access management, networking configuration etc.

### Documentation with the enablement framework
Go over each question and as far as it's possible answer the questions based on what the service can and cannot do.

Not all questions are relevant to all services. 

**Example**
| Questions | Answer | Description |
|---|---|---|
| Does the service have a public endpoint? | Yes |By default service X has a public endpoint. With the use of disable public network access and private endpoint the service can get a private ip. |
 
### Governance (Azure Policy)
With the given example above, this provides the opportunity to leverage Azure Policy to ensure automated governance in the Azure platform. If the organization or management group scope does not allow public endpoints, one might recommend an Azure policy to prevent the creation of the service with public endpoint.


### Onboarding & Enablement
After the service is detailed, understood and documented with guardrail policy recommendations, you are able to either:
* a) Release the service into the platform
* b) Conclude not to release it into the platform, for now

## How this enables controlled adoption
The team handling the platform become the gateway for releasing services from the marketplace into the landing zones. All services are documented and understood before committing to release them into the platform.

## Trade-offs and considerations
This approach might not be a one-size-fits-all, but for large organizations wanting stricter control on Azure marketplace is a great supplement to the release strategy from a platform point of view.

## Final thoughts
This is as much an organizational process as a technical one, and the value compounds as the enabled service catalog grows. 

I never touched upon who owns the process - and there is a reason for that. One might argue it is the platform engineers, one might argue its the Architects or Cloud Center of Excellence. Whoever it is, the knowledge should not live in a silo — the work is inherently cross-functional, sitting at the intersection of platform engineering, architecture, and governance.

## References
[Service Enablement Framework - Microsoft Learn](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/service-enablement-framework)
