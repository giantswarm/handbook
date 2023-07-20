---
title: "How to manage an incident FAQ"
owner:
- https://github.com/orgs/giantswarm/teams/team-horizon
confidentiality: public
---

# FAQ

1. What are the P1/P2 severities?

For simplification there are only two severities, critical (P1) or routine (P2). Critical incidents are those which impair a customer production system. Routine incidents are all other regular incidents which don’t impact production and which have a straightforward process.

2. What do the different roles mean? When should they be used? What does setting them do?

There are two roles, Incident Coordinator who acts as communicator and driver of the incident and Operation Engineer(s) who has the responsibility to investigate the problem. For not critical incidents (P2), Incident Coordinator is not needed and Operation Engineer act as both roles. 

[More info](https://docs.giantswarm.io/support/p1-process/#roles)

3. What is the correct way to contact a customer if needed? 

Every incident declared there is a link to the Customer Escalation Matrix which redirect you to intranet customer page.

4. When is it appropriate to escalate or page another areas on-caller? How do you do that?

In critical processes (P1), the Incident Coordinator will decide together with Operation Engineer when someone else is needed. In case of a routine incident (P2), Operation Engineer should decide when to escalate it based on the impact and knowledge about the problem. To escalate use `/inc escalate` (or the button) in the incident channel and select the team or person that you want to target.

__Note__: To call for an incident coordinator you can select the `incident_coordinators` group in the `Who I need?` popup window when you escalate through incident.io.

4. How to silence an alert out-of-hours.

Silences are managed in a [single repo](https://github.com/giantswarm/silences/) and they are a especial Custom Resource. Create a new resource copying from existing and modifying cluster/installation names. If you are in the middle of the night don't hesitate to merge without approval. [More info](https://intranet.giantswarm.io/docs/support-and-ops/processes/silence-management/).

5. How should I raise issues I discover during debugging? Do all need issues creating? 

Create a [new postmortem](https://github.com/giantswarm/giantswarm/issues/new?assignees=&labels=postmortem%2C+team%2Fnull&template=operations-postmortem.md&title=) that will collect on the main data about the problem and team will take it based on priority.

# Further links

- [Official docs for P1 process](https://docs.giantswarm.io/support/p1-process/)
