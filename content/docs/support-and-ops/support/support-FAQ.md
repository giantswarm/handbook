---
title: "Support FAQ"
owner:
- https://github.com/orgs/giantswarm/teams/team-teddyfriends
confidentiality: public
---

This page contains useful information for qualifying and identifying issues raised on support.

## Support Template: qualifying a request

The first thing a person on support needs to understand is where the issue is happening and what is the scope of the issue. This is important because it will help us to understand if the issue is related to the platform or not and how urgent it is.

A good way to do this is to gather enough information to answer all the following questions:

- Which installation (Management Cluster) is affected?
- Is the problem affecting the Management Cluster or a Workload Cluster? In the latter case, which Workload Cluster is it?
- What is the impact? Can users "feel it", or is it just a warning or a red light in some monitoring tool?
- Is the issue affecting a single user or multiple users?
- Is the issue affecting multiple clusters? If so, which ones?
- If the issue is affecting multiple clusters, which cluster is the "most important" one?
- Did anything change in the cluster recently?
- Is the issue a real issue, or is it just a question about how to do something or a feature request? If it is not an issue, we can move the discussion to a GitHub issue.

## What is expected of the on-support Solutions Engineer?

A Solutions Engineer on support shall:

- qualify the request by following the [Support Template](#support-template-qualifying-a-request)
- try to perform basic debugging according to opsrecipes/FAQ entries (look at pods logs, check if nodes are Ready, ...)
- drive communication with the customer. This will allow us to have a more diverse face to the customer and not always the same people solving problems even though they might have helped in the background.
- pull a support person from a specific team (e.g. Cabbage) in the incident channel to help in case they are not able to figure out what's broken/how to fix it
- create/update FAQ entries as needed. Notice that, whereas an opsrecipe states _how_ to fix an issue, an FAQ entry includes useful information for debugging, focusing on the _why_ certain steps are taken
- mark the support requests that are interesting/problematic so that we can talk about them on Thursday in the AE-SA meeting. We make sure we talk about past requests and learnings across all and make sure teams are aware of the priorities.
- create a GitHub issue for the request if it is not an issue but a question or a feature request. This will allow us to track the request and make sure it is not lost

## What is expected of each team's on-support engineer (`@support-$TEAM` on Slack)?

Each team is required to always have a person available to help with support requests during Business Hours (09:00 - 18:00 German time). Each team has total freedom in choosing *who* is on support. Some common setups, each one with its pros and cons, are:
- the Solutions Architect for the team is the person always on support for the team
- the on-call engineer for the team is also the engineer that responds to the `@support-$TEAM` mentions on Slack (this can be automated via [Ailefroide](https://github.com/giantswarm/ailefroide-app/))
- a pool of engineers responds to the `@support-$TEAM` mentions on Slack

Whenever the Solutions Engineer (SE) on support pings `@support-$TEAM` on Slack, the team's on-support engineer shall:
- join the incident channel created by the Solutions Engineer
- NOT take over (at least not *fully*), but pair with the SE on support using the incident channel and possibly joining the _support lounge_ (pinned in both the `#support` and `#chapter-se` Slack channels). This is important for various reasons such as upskilling the SE on support and making sure the SE on support is not left alone
- help the SE on support to write an FAQ entry on how the issue was debugged, mostly by validating the FAQ entry written by the SE against mistakes (if needed)
- NOT leave the person on support hanging: if they are not able to help for any reason, they have the responsibility to find someone from their team who can take over as domain-expert

## Cheatsheet

### How do I get a list of the AWS Vintage clusters have the `alpha.aws.giantswarm.io/enable-cloudfront-alias` annotation?

While logged in the Management Cluster, run the following command: `kubectl get awscluster --all-namespaces -o json | jq -r '.items[] | select(.metadata.annotations | to_entries[] | .key | startswith("alpha.aws.giantswarm.io/enable-cloudfront")) | .metadata.name'`

### How do I trigger a CloudFormation stack reconciliation?

Follow [this guide]({{< relref "/docs/support-and-ops/ops-recipes/cf-stack-reconciliation.md" >}}).

### How do I fix a AWS Vintage cluster that wasn't upgraded to >v18.4.0 directly after adding the IRSA annotation (migration from KIAM)

The cluster will throw errors like these: `"WebIdentityErr: failed to retrieve credentials\ncaused by: AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity\n\tstatus code: 403"`

The root cause may be that the `alpha.aws.giantswarm.io/enable-cloudfront-alias: ""` was added without upgrading the cluster afterwards, see details [here](https://github.com/giantswarm/releases/blob/cbac05e314f4bcd4caedc8350ebbe804b902f108/aws/v18.4.0/README.md?plain=1#L8)

Example case of this happening, [in this Slack thread](https://gigantic.slack.com/archives/C268Q4WNL/p1688719236782879)

In order to fix this, the `tccpn` stack needs to be updated as follows: 
1. Go to CloudFormation of WC
2. find $clusterid-tccpn 
3. update -> edit in designer -> add "-trigger" at the end of the value for OperatorVersion (e.g. "Value: 14.13.3-trigger")
4. NextNextNext / set checkmark / submit
5. tccpn stack rolls: done!

