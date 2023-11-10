---
title: Glossary
linkTitle: Glossary
weight: 100
description: Terminology used by Giant Swarm in internal and external communication.
icon: fa fa-sort-alpha-down
confidentiality: public
---
## Intro

- Terms and abbreviations commonly used at Giant Swarm.
- Where we care, the exact capitalization is mentioned.
- If something is missing please open a [pull request](https://github.com/giantswarm/handbook/edit/main/content/docs/glossary/_index.md). 🙏
- Roles and job titles are documented over at [Roles & Habits @ Giant Swarm](https://handbook.giantswarm.io/docs/people/reading-material/onboarding-roles/)
- Your future colleagues and future self will thank you. ❤️

---

## A

### Ambassador

Someone who is responsible for the information flow between your team and a certain SIG (both directions). See [Ambassadors for SIGs]().

### Area {#area}

A combination of multiple teams e.g. the "Kubernetes as a Service" (KaaS) Area.

### Architecture decision record (ADR)

A document which records architectural decisions and its consequences.

### App

The term _app_ could refer to (1) the concept of apps in general (e.g. kong, redis, etc.) or (2) an entry in an App Catalog.

We do not differentiate between `app` vs `App`, as it easy to make a capitalization mistake when typing. We also do not use `applications` in the context of Managed Services or Managed Apps.

See also: [Managed App](#managed-app)

### App Catalog

`an App Catalog` can refer to a specific catalog, i.e. the "Giant Swarm Catalog" or "Control Plane Catalog".

### App Platform

In contrast to [Managed Apps](#managed-app), App Platform is the tooling (i.e. app-operator and chart-operator) that enables the creation and maintenance of Apps.

---

## B

### Bring your own cloud (BYOC)

Deprecated. The former name associated with the [multi-account support](#multi-account-support) functionality.

---

## C

### Chapter

A group of people with the same role (possibly limited by [Area](#area)) like PEs of SaaS Area, POs, SAs, Recruiters, Sales.

### Client certificate {#client-certificate}

X.509 certificate used by a client to authenticate with a server. In the Giant Swarm context, client certificates are a common authentication means (but not the only one) for the Kubernetes API. For example, we provide tooling to help end users create client certificates to access their workload clusters.

Formerly called _key pair_, since the client needs both a private key and the certificate (public key) to authenticate. We switched to the term _client certificate_ to align with the terminology used by the Kubernetes project.

### Cluster API

From the [book](https://cluster-api.sigs.k8s.io/): "Cluster API is a Kubernetes sub-project focused on providing declarative APIs and tooling to simplify provisioning, upgrading, and operating multiple Kubernetes clusters.". In other words: Cluster API enables Kubernetes to manage Kubernetes clusters.

Internally Cluster API is also abbreviated as CAPI. In our written communication, please avoid the abbreviation and always use the full spelling in title case.

Do not use:

- CAPI
- cluster API
- ClusterAPI

---

## D

---

## E

### End to end (E2E) test {#e2e-test}

An automated test for an application flow from start to end. To simulate real user scenarios and validate the system under test.

For Giant Swarm an example is running the Kubernetes conformance tests against a workload cluster. Whereas an _integration test_ only tests a single component within the Giant Swarm release.

---

## F

---

## G

---

## H

### High-availability control plane

A feature of our product indicating that workload clusters are provisioned with three control plane nodes instead of one. See our [public docs](https://docs.giantswarm.io/advanced/high-availability/control-plane/) for details.

### High-availability Kubernetes masters

Deprecated, former name for [high-availability control plane](#high-availability-control-plane).

---

## I

### Identity provider (IdP)

"A system entity that creates, maintains, and manages identity information for principals while providing authentication services to relying applications within a federation or distributed network." Our SSO uses Azure AD and GitHub as our identity providers.

### Installation

The overall environment managed for a customer used as a landing zone by Giant Swarm to install the needed infrastructure to run your workloads. Includes eventual Cloud Provider specific accounts.

### Integration test

An integration test tests an individual component to expose defects in that component or how it interacts with other components.

For Giant Swarm an example is a test for an operator which runs in a [KIND](#kind) cluster in Circle CI. It differs from an [end-to-end test](#e2e-test) which tests an entire Giant Swarm release.

---

## J

---

## K

### Key pair

Now called [client certificate](#client-certificate).

### KIND

**Kubernetes in Docker** is an upstream tool for running local Kubernetes clusters using Docker container “nodes”. See [official docs](https://kind.sigs.k8s.io/docs/user/quick-start/) for more information.

---

## L

### Legacy

**A legacy release** is any release made prior to Cluster API. You can find all legacy releases in [our release repository](https://github.com/giantswarm/releases/blob/master/README.md). Check [Vintage product](#vintage-product) to know more why is still relevant.

---

## M

### Managed App

A `Managed App` is an app we actively manage for customers, i.e. the apps in the Giant Swarm Catalog (Ingress NGINX Controller, Kong, EFK, etc.).

`Managed Apps` is also shorthand for the "Managed Apps Area," which comprise of the members of Team Batman and Team Halo.

These are NOT Managed Apps

- Apps in the Playground Catalog are Playground Apps. They are not managed, but are "supported with best-effort." See: [Giant Swarm Management and Support Description](https://docs.google.com/document/d/1IujvU9N2wESvQGnJ3wJcO5fYAMKSkdwaDWunefOzQ_M/edit) for more.
- app-operator and chart-operator. They collectively make up the [App Platform]({{< relref "/docs/glossary/[_index.md#app-platform](_index.md#app-platform)" >}}).

### Management cluster (MC)

A Kubernetes cluster running Giant Swarm specific management components essential for the installation.

Formerly called "control plane", often abbreviated as "CP".

### Management clusters fleet (MCF)

Legacy gitOps configuration for management clusters. Initially, we kept it all in one repo named `management-clusters-fleet`. Later we split this up for security/permission reasons.

See: MCB, CMC

### Management cluster bases (MCB)

Manifests management clusters are built on and shared between multiple MCs / customers, for example provider bases (aws,capa,capz,gcp,etc.), our flux setup and optional extra components like external-secrets, crossplane, etc.

Located at: [https://github.com/giantswarm/management-cluster-bases](https://github.com/giantswarm/management-cluster-bases)

### Customer management clusters (CMC)

Customer repository for holding the actual MC gitops repository, containing the customer MCs. Builds on MCB by using Flux remote bases.

Repository name must follow the naming convention: `<CUSTOMER_NAME>-management-clusters`, e.g: `giantswarm-management-clusters`.

### Management cluster initializer (MCI)

The AWS CloudFormation Stack created for each workload cluster where we manage VPC Peering Connections.

### Management API

The Kubernetes API of the management cluster.

Internally this is also often abbreviated as `MAPI`, however we don't use that abbrevation in external communication.

Spelling: Always spelled `Management API` with an uppercase `M`.

### Multi-account support {#multi-account-support}

The ability for a management cluster to manage accounts and launch workload clusters outside its default accounts. The functionality formerly known as Bring Your Own Cloud (BYOC).

---

## N

---

## O

---

## P

### Postmortem

A Postmortem is a specialized workflow, typically towards resolving operational issues. See our [docs](https://docs.giantswarm.io/support/overview/#postmortem-process). Often abbreviated as "PM".

### Post deploy verification (PDV)

Is a column in most of our GitHub project boards. When an issue is closed the automation moves it to this column. This gives us the chance to check that changes are documented and communicated (internally and / or externally, whatever applies) before archiving the issue.

### Platform Engineer (PE)

A backend developer at Giant Swarm that works mainly on automation within our product. SIG Operator is the SIG of Platform Engineers.

---

## Q

---

## R

### Rockefeller Habits

A framework for business growth.

See this [introduction](https://blog.growthinstitute.com/scale-up-blueprint/10-rockefeller-habits-checklist).

---

## S

### Special interest group (SIG)

SIGs are a long term concept where people interested in a certain topic or stakeholders in the topic meet regularly. The goal of the SIG is to continuously find alignment and a shared vision of the topic across the company (represented by the people that join).

Therefore ideas, implementation plans or questions can be brought to a SIG for alignment, reflection and advice. Each SIG has a driver who acts as a facilitator for the SIGs meetings and rituals.

For more information, please refer to this [blog post](https://www.giantswarm.io/blog/the-giant-swarm-model-explained)

### Single sign-on (SSO)

The concept of using one identity to authenticate with different services. E. g. using a Google account to authenticate for a Software as a Service (SaaS) like LastPass.

### Special working hours (SWH)

Time allocated for specific SIG work. Usually one hour bi-weekly. People get together and work on what they are interested in, within the scope of the particular SIG.

---

## T

---

## U

### Unit test

A Unit Test is an automated test that tests a section of application code. It differs from an `Integration Test` because it only tests part of the code and should not make network calls to external systems.

At Giant Swarm we focus unit tests on complex or error prone code rather than targeting overall coverage. See [giantswarm/fmt](https://github.com/giantswarm/fmt/blob/master/go/unit_tests.md#unit-tests) for more details.

---

## V

### Vintage product

This is the previous generation of our product and is still in production with many of our customers. We still actively support this generation. However, the development focus is limited to main customer needs and supporting the migration to our CLuster API-based implementations.

---

## W

### Working group (WG)

WGs are a short term concept where people willing to work on a specific task (across different teams) meet.

A WG therefor has a narrowly defined, actionable goal statement which it can realistically  achieve with the number of people participating. It dissolves itself once the members of a WG have achieved that goal in their own perception.

Check this [blog post](https://www.giantswarm.io/blog/the-giant-swarm-model-explained?hs_preview=ywLStKPF-34462108164) for more information.

### Workload cluster (WC)

A Kubernetes cluster running customer specific workloads. It is managed by some management cluster.

Formerly called

- "tenant cluster", often abbreviated as "TC"
- "guest cluster"

### Workload cluster release

The software stack comprising a workload cluster.

---

## X

---

## Y

---

## Z




