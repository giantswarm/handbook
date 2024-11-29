# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- New recipe for Kyverno stuck in upgrade pending.
- MC types to glossary (ephemeral and stable-testing)
- Added `kubectl debug` info in Troubleshooting recipe

### Changed

- Update docsy to v0.9.0
- Lower resource requests and limits, make them configurable
- Change front-matter field `confidentiality` to `classification` to align with ISMS
- Fix ISMS links in remote-work-checklist page
- Minor corrections in code signing howto
- Migrate to `app-build-suite`

## [0.13.0] - 2024-02-16

## [0.12.0] - 2024-02-16

### Changed

- Updated the repo creation docs with the updated renovate process
- Render RFCs
- Updated Loki handbook by fixing some queries
- Synchronize local environment (docker-compose.yaml) with updated production environment
- Switch to public `staticjscms-hugo-standalone` image instead of private ghcr.io one
- Compress static output files using gzip, remove uncompressed HTML files
- Update chart to be deployable on K8s 1.25 wit Pod Security Standards enabled

## [0.11.0] - 2023-10-19

### Added

- Add instructions on how to create a new App repo.

## [0.10.7] - 2023-10-17

### Added

- Fix ingress prefix path
- Mount CMS config from secret

## [0.10.6] - 2023-10-16

### Added

- Fix wrong secret key reference in static-cms deployment container spec

## [0.10.5] - 2023-10-16

### Added

- Adapt staticjscms-hugo-standalone secret to changes (`ORIGIN` -> `ORIGINS`)

## [0.10.4] - 2023-10-16

### Added

- Fix secret string quoting

## [0.10.3] - 2023-10-16

### Added

- Fix secret template to output more than one secret

## [0.10.2] - 2023-10-13

- Fix secret templates and values

## [0.10.1] - 2023-10-11

### Added

- Encode secret values using base64 encoding

## [0.10.0] - 2023-10-10

### Added

- Static CMS configuration (secret)

## [0.9.0] - 2023-10-08

### Added

- Add customized Static CMS setup (editor)

## [0.8.0] - 2023-10-05

### Added

- Add instructions on how to create a new Go repo.

## [0.7.1] - 2023-09-21

### Fixed

- Fixed images path in Loki usage and Loki cost guides

## [0.7.0] - 2023-09-19

### Added

- Add page about IDE configuration

## [0.6.0] - 2023-09-19

### Added

- Add Observability top level menu item
  - Move observability files and images

## [0.5.0] - 2023-09-15

### Added

- Update Loki usage guide
  - Add LogQL basic
  - Update context and access sections
  - Update & fix images
- Add Loki cost guide

## [0.4.1] - 2023-08-31

### Fixed

- Add Loki usage guide images

## [0.4.0] - 2023-08-31

### Added

- Add Loki usage guide

## [0.3.4] - 2023-08-23

## [0.3.3] - 2023-08-18

## [0.3.2] - 2023-08-17

## [0.3.1] - 2023-08-11

### Added

- Ignore more private URLs in linkchecker.

## [0.3.0] - 2023-08-02

- Add page about developer portal

## [0.2.0] - 2023-07-27

### Added

- Instructions on Karpenter

## [0.1.2] - 2023-07-27

### Added

- A page for incident management FAQ.

## [0.1.1] - 2023-07-14

### Added

- Instructions for writing a Cronjob to patch resources

## [0.1.0] - 2023-07-14

### Added

- Tutorial on CloudFormation stack reconciliation

## [0.0.20] - 2023-07-11

## [0.0.19] - 2023-06-29

- Moved SIG docs content pages to handbook
### Added

- Added "How to write documentation" page from intranet.

### Changed

- Docs: Rename `nginx-ingress-controller` to `ingress-nginx-controller`. ([#82](https://github.com/giantswarm/handbook/pull/82))


## [0.0.18] - 2023-06-14

## [0.0.17] - 2023-06-14

- fixed image links in `proxy` documentation

## [0.0.16] - 2023-06-14

- Add notes about the current `proxy` implementation for Management- and Workload-Clusters

## [0.0.15] - 2023-05-31

## [0.0.14] - 2023-05-17

## [0.0.13] - 2023-05-16

## [0.0.12] - 2023-05-11

### Added

- Add an ops recipe for Master usage CPU too high.

### Changed

- Updated `Troubleshooting gitops` with customer communication section

## [0.0.11] - 2023-04-20

### Added

- A directive in Dockerfile to disable absolute redirects
- Add an ops recipe to troubleshoot GitOps environments

### Changed

- Reword "Registry Mirrors" article to focus on current state of containerd but still mention historical context for Docker daemon behavior
- Avoid the term "private" for registries that we control since the images can be pulled publically and anonymously
- Fix invalid redirects on request URLs without trailing slash (enable relative redirects)

## [0.0.10] - 2023-03-23

### Fixed

- Fix multiple broken links and markdown formatting.

## [0.0.9] - 2023-03-21

### Added

- Added note about AWS CNI Pod subnets in the Cilium to AWS switch document.

## [0.0.8] - 2023-03-17

### Added

- Add code signing documentation
- Add initial content for people area.
- Add `page-meta-links.html` for proper link formatting.

## [0.0.7] - 2023-03-13

### Fixed

- Fix typo in Cilium upgrade recipe process for AWS

## [0.0.6] - 2023-03-13

### Added

- Add Cilium upgrade recipe process for AWS

## [0.0.5] - 2023-03-06

### Added

- Background image and layout from intranet.

## [0.0.4] - 2023-03-02

### Added

- Additional `docs` layer to match intranet layout.

## [0.0.3] - 2022-09-06

### Added

- Add content on git subtrees.

## [0.0.2] - 2022-09-05

### Added

- Add initial public content.

## [0.1.0] - 2022-01-05

### Added

- Initial docsy setup.

[Unreleased]: https://github.com/giantswarm/handbook/compare/v0.13.0...HEAD
[0.13.0]: https://github.com/giantswarm/handbook/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/giantswarm/handbook/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/giantswarm/handbook/compare/v0.10.7...v0.11.0
[0.10.7]: https://github.com/giantswarm/handbook/compare/v0.10.6...v0.10.7
[0.10.6]: https://github.com/giantswarm/handbook/compare/v0.10.5...v0.10.6
[0.10.5]: https://github.com/giantswarm/handbook/compare/v0.10.4...v0.10.5
[0.10.4]: https://github.com/giantswarm/handbook/compare/v0.10.3...v0.10.4
[0.10.3]: https://github.com/giantswarm/handbook/compare/v0.10.2...v0.10.3
[0.10.2]: https://github.com/giantswarm/handbook/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/giantswarm/handbook/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/giantswarm/handbook/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/giantswarm/handbook/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/giantswarm/handbook/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/giantswarm/handbook/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/giantswarm/handbook/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/giantswarm/handbook/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/giantswarm/handbook/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/giantswarm/handbook/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/giantswarm/handbook/compare/v0.3.4...v0.4.0
[0.3.4]: https://github.com/giantswarm/handbook/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/giantswarm/handbook/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/giantswarm/handbook/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/giantswarm/handbook/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/handbook/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/giantswarm/handbook/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/giantswarm/handbook/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/handbook/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/handbook/compare/v0.0.20...v0.1.0
[0.0.20]: https://github.com/giantswarm/handbook/compare/v0.0.19...v0.0.20
[0.0.19]: https://github.com/giantswarm/handbook/compare/v0.0.18...v0.0.19
[0.0.18]: https://github.com/giantswarm/handbook/compare/v0.0.17...v0.0.18
[0.0.17]: https://github.com/giantswarm/handbook/compare/v0.0.16...v0.0.17
[0.0.16]: https://github.com/giantswarm/handbook/compare/v0.0.15...v0.0.16
[0.0.15]: https://github.com/giantswarm/handbook/compare/v0.0.14...v0.0.15
[0.0.14]: https://github.com/giantswarm/handbook/compare/v0.0.13...v0.0.14
[0.0.13]: https://github.com/giantswarm/handbook/compare/v0.0.12...v0.0.13
[0.0.12]: https://github.com/giantswarm/handbook/compare/v0.0.11...v0.0.12
[0.0.11]: https://github.com/giantswarm/handbook/compare/v0.0.10...v0.0.11
[0.0.10]: https://github.com/giantswarm/handbook/compare/v0.0.9...v0.0.10
[0.0.9]: https://github.com/giantswarm/handbook/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/giantswarm/handbook/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/giantswarm/handbook/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/giantswarm/handbook/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/giantswarm/handbook/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/giantswarm/handbook/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/giantswarm/handbook/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/giantswarm/handbook/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/giantswarm/handbook/releases/tag/v0.0.1
