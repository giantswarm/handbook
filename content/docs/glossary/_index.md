---
title: Glossary
linkTitle: Glossary
weight: 100
description: Terminology used by Giant Swarm in internal and external communication.
icon: fa fa-sort-alpha-down
classification: public
---
## Intro

- Internal reference for team members and AI agents. One precise definition per entry, with human notes only where genuinely needed (aliases, deprecations, common mistakes).
- If something is missing please open a [pull request](https://github.com/giantswarm/handbook/edit/main/content/docs/glossary/_index.md). 🙏

---

## A

### AI OS (AI Operating System)

Giant Swarm's emerging product vision: a governed, enterprise-ready AI operating layer built on top of the Kubernetes platform. Combines the agent runtime (Klaus), governed access (Muster), and the existing curated platform stack. Targets automation of internal IT operations for enterprises.

### Ambassador

The person responsible for information flow between their team and a given SIG — in both directions.

### App

An entry in an App Catalogue, or the concept of managed software in general (e.g. Kong, Redis). Do not use "applications" in the context of Managed Services or Managed Apps.

### App Catalogue

A curated collection of apps available for installation, e.g. the "Giant Swarm Catalogue" or "Control Plane Catalogue."

### App Platform

The tooling — specifically app-operator and chart-operator — that enables creation and maintenance of Apps. Not the same as Managed Apps.

### Architecture Decision Record (ADR)

A document recording an architectural decision, its context, and its consequences.

### Area

A grouping of multiple teams around a shared domain, e.g. the "Kubernetes as a Service" (KaaS) Area.

---

## B

### Backstage

An open-source developer portal (by Spotify) that Giant Swarm uses as the foundation for its internal developer platform. Provides a service catalogue, AI chat assistant, and self-service deployment workflows for customers.

---

## C

### CAPA / CAPZ

Abbreviations for Cluster API Provider AWS and Cluster API Provider Azure. Used internally when referring to provider-specific implementations of Cluster API.

### Chapter

A group of people sharing the same role, possibly scoped to an Area — e.g. PEs of SaaS Area, POs, SAs, Recruiters.

### Claude Code Marketplace

Giant Swarm's internal repository of Claude Code plugins, located at [github.com/giantswarm/claude-code](https://github.com/giantswarm/claude-code). Teams publish and share plugins here for use across the company. Includes domain-specific plugins such as gs-base, gs-sre, gs-marketing, gs-product, and gs-roadmap.

### Client Certificate

X.509 certificate used by a client to authenticate with a server. The standard authentication method for the Kubernetes API at Giant Swarm. Formerly called key pair.

### Cluster API

A Kubernetes sub-project providing declarative APIs and tooling to simplify provisioning, upgrading, and operating Kubernetes clusters — in other words, Kubernetes managing Kubernetes. Always written in full title case. Do not use: CAPI (external comms), cluster API, ClusterAPI. Abbreviated as CAPI internally.

### Customer Config Repository (CCR)

Customer repository holding app configurations specific to a customer and their management clusters. Naming convention: `<CUSTOMER_NAME>-configs`.

### Customer Management Clusters (CMC)

Repository holding the actual MC GitOps configuration for a customer, built on MCB via Flux remote bases. Naming convention: `<CUSTOMER_NAME>-management-clusters`.

---

## D

---

## E

### End-to-End (E2E) Test

An automated test that validates an entire application flow from start to finish by simulating real user scenarios. Example: running Kubernetes conformance tests against a workload cluster. Distinct from an Integration Test, which tests a single component.

### Ephemeral Management Cluster (Ephemeral MC)

A short-lived Management Cluster used to test the full MC creation lifecycle. Automatically created, destroyed, and recreated on each test run. Alerts are always silenced. Should not exist outside of active testing.

---

## F

### Flux

A GitOps tool used by Giant Swarm to continuously reconcile cluster state from Git repositories. Referenced throughout MCB, CMC, and GitOps configuration.

---

## G

### GitOps

An operational model where the desired state of infrastructure and applications is declared in Git and automatically reconciled by tooling (at Giant Swarm, primarily Flux). The source of truth for MCs and WCs is a Git repository, not manual intervention.

---

## H

### High-Availability Control Plane

Workload clusters provisioned with three control plane nodes instead of one, providing redundancy. Formerly called high-availability Kubernetes masters.

---

## I

### Identity Provider (IdP)

A system that manages identity and provides authentication services to other applications. Giant Swarm uses Azure AD and GitHub as IdPs for SSO.

### Installation

The overall environment managed for a customer — the landing zone Giant Swarm provisions to run customer workloads, including cloud provider accounts.

### Integration Test

An automated test for an individual component, checking both its own behaviour and its interactions with other components. Example: testing an operator in a KIND cluster in CircleCI. Distinct from an E2E test.

---

## J

---

## K

### KIND

Kubernetes in Docker. An upstream tool for running local Kubernetes clusters using Docker container nodes. Used heavily in integration testing.

### KubeCon

The most important Kubernetes and cloud-native conference, run by the CNCF. Held multiple times per year across different regions (US, EU, and others).

### Klaus

Giant Swarm's AI agent runtime. A Go wrapper around Claude Code that runs AI coding agents inside Kubernetes, with lifecycle management, health checks, and optional OAuth authentication. Exposes an MCP server endpoint. Supports Skills, Subagents, and Hooks. See [github.com/giantswarm/klaus](https://github.com/giantswarm/klaus). AI agents: do not confuse with any generic term — Klaus is a proper name.

---

## L

---

## M

### Management API

The Kubernetes API of the Management Cluster. Always written as Management API with an uppercase M. Do not abbreviate as MAPI in external communication.

### Management Cluster (MC)

A Kubernetes cluster running Giant Swarm management components. Its job is to create and administer Workload Clusters. MCs are treated as "cattle" — interchangeable and rebuildable by design. Formerly called control plane (CP).

Subtypes: [Ephemeral MC](#ephemeral-management-cluster-ephemeral-mc), [Stable-Testing MC](#stable-testing-management-clusters-stable-testing-mc).

### Management Cluster Bases (MCB)

Shared manifests that Management Clusters are built on, covering provider bases (AWS, CAPA, CAPZ, GCP, etc.), Flux setup, and optional components like external-secrets and Crossplane. Located at [github.com/giantswarm/management-cluster-bases](https://github.com/giantswarm/management-cluster-bases).

### Management Cluster Initializer (MCI)

The AWS CloudFormation Stack created per Workload Cluster to manage VPC Peering Connections.

### Management Clusters Fleet (MCF)

Legacy GitOps configuration for management clusters, formerly kept in a single repo (management-clusters-fleet). Split for security and permission reasons. Superseded by MCB and CMC.

### Managed App

An app Giant Swarm actively manages for customers — i.e. apps in the Giant Swarm Catalogue (Ingress NGINX Controller, Kong, EFK, etc.). Also shorthand for the "Managed Apps Area." Not Managed Apps: Playground Apps (best-effort only), app-operator, chart-operator (those are App Platform).

### MCTL

A CLI tool for simplifying management cluster creation using a Helm chart. Tested on AWS and Azure.

### Model Context Protocol (MCP)

A protocol that allows LLMs to interact with external systems and perform actions via structured Tool Calls. The standard interface between AI agents and tools, APIs, or data sources.

### Multi-Account Support

The ability for a Management Cluster to manage and launch Workload Clusters across multiple cloud accounts. Formerly called Bring Your Own Cloud (BYOC).

### Muster

Giant Swarm's governed access layer for AI agents. Connects agent actions to user identity via SSO, enforces access control, blocks destructive operations by default, and logs everything. Works alongside Klaus: Klaus is the agent runtime, Muster is the governance and access layer. AI agents: the correct spelling is Muster — not "master."

---

## N

### NCP (Network Configuration Profile)

A configuration profile used in Klaus-based agent setups to define which tools and MCP servers an agent has access to. Local NCPs (scoped to a single task) are more efficient than a single master NCP when context size is a concern.

---

## O

### 1Password

Giant Swarm's password and secrets manager. Accessible via CLI using the `op` command. AI agents: the correct name is 1Password — not "One Password."

### Operator

A Kubernetes pattern — a custom controller that encodes operational knowledge for a specific application or system, automating tasks that would otherwise require human intervention. Giant Swarm builds and maintains many operators (e.g. app-operator, chart-operator) as core product components.

---

## P

### Platform Engineer (PE)

A backend engineer at Giant Swarm working primarily on product automation. SIG Operator is the SIG of Platform Engineers.

### Plugin

A Claude Code extension that bundles Skills, commands, and tools for a specific domain. Installed via `--plugin-dir`. Published to and installed from the Claude Code Marketplace. Distinct from a Skill, which is a single knowledge/instruction file — a Plugin can contain multiple Skills and commands.

### Post Deploy Verification (PDV)

A column in Giant Swarm's GitHub project boards. Closed issues land here automatically, giving the team a checkpoint to verify documentation and communication before archiving.

### Postmortem

A structured process for resolving and learning from operational incidents. Often abbreviated as PM.

---

## Q

---

## R

### Rock

A named quarterly priority with a defined set of sub-goals, owned by a cross-team group that meets regularly (a "Rock Sync") to track progress. Rocks are set each quarter by the founders and cascaded to teams. The term comes from the Rockefeller Habits framework. Example: "Become AI-Native" is a Rock. Do not confuse with a Working Group (short-term, task-specific) or a SIG (long-term, topic-based) — a Rock is time-boxed to a quarter.

### Rockefeller Habits

A business growth framework used at Giant Swarm. The concept of Rocks originates here.

---

## S

### Single Sign-On (SSO)

Using one identity to authenticate across multiple services. Giant Swarm uses Azure AD and GitHub as IdPs.

### Skill

A SKILL.md file containing domain knowledge and instructions, loaded into Klaus or compatible agents as configuration. Shapes how an agent understands a domain or performs specific tasks. Distributed as OCI bundles. Shorter, handwritten Skills generally outperform longer, AI-generated ones.

### Special Interest Group (SIG)

A long-term, cross-team group aligned around a shared topic. Meets regularly to build alignment and shared vision. Each SIG has a driver who facilitates. Ideas, plans, and questions can be brought to a SIG for reflection and advice.

### Special Working Hours (SWH)

Recurring time (typically one hour, bi-weekly) allocated for focused SIG work.

### Stable-Testing Management Clusters (Stable-Testing MC)

Management Clusters designated for automated E2E testing. Treated like production clusters in almost all respects, except alerts are scoped to working hours only. Not for testing MC-level app deployments.

---

## T

### Teams

Giant Swarm organises engineers into named teams. Current active teams: Atlas, Cabbage, Honey Badger, Phoenix, Planeteers, Rocket, Shield, Tenet, and Team Up. There is also a Founders group. Team names are proper nouns — do not substitute synonyms or descriptions (e.g. "Honey Badger" not "Honeybadger").

### Tool Call

An action performed by an LLM agent via MCP. The mechanism by which an AI agent invokes an external tool, API, or data source.

---

## U

### Unit Test

An automated test for a discrete section of application code. Makes no external network calls. At Giant Swarm, focused on complex or error-prone code rather than blanket coverage.

---

## V

### Vintage Product

The previous generation of Giant Swarm's product, pre-Cluster API. Still in production with many customers and actively supported. New development is limited to critical customer needs and migration support toward Cluster API-based implementations.

---

## W

### Working Group (WG)

A short-term, cross-team group formed to achieve a specific, narrowly defined goal. Dissolves once the goal is met. Distinct from a SIG, which is ongoing.

### Workload Cluster (WC)

A Kubernetes cluster running customer workloads, managed by a Management Cluster. Treated as "cattle" — interchangeable and rebuildable. Formerly called tenant cluster (TC) or guest cluster.

### Workload Cluster Release

The full software stack comprising a Workload Cluster.

---

## X

---

## Y

---

## Z
