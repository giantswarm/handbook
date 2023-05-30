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

## What's expected of the on-support engineer?

A Solutions Engineer on support shall:

- qualify the request by following the [Support Template](#support-template-qualifying-a-request)
- try to perform basic debugging according to opsrecipes/FAQ entries (look at pods logs, check if nodes are Ready, ...)
- drive communication with the customer. This will allow us to have a more diverse face to the customer and not always the same people solving problems even though they might have helped in the background.
- pull a support person from a specific team (e.g. Cabbage) in the incident channel to help in case they are not able to figure out what's broken/how to fix it
- create/update FAQ entries as needed. Notice that, whereas an opsrecipe states _how_ to fix an issue, an FAQ entry includes useful information for debugging, focusing on the _why_ certain steps are taken
- mark the support requests that are interesting/problematic so that we can talk about them on Thursday in the AE-SA meeting. We make sure we talk about past requests and learnings across all and make sure teams are aware of the priorities.
- create a GitHub issue for the request if it is not an issue but a question or a feature request. This will allow us to track the request and make sure it is not lost
