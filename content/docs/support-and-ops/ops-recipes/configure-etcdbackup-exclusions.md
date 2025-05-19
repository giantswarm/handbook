---
title: "Configure ETCDBackup Exclusions"
owner:
- https://github.com/orgs/giantswarm/teams/team-planeteers
component:
  - etcd-backup-operator
description: "How to configure ETCDBackup custom resource to exclude specific clusters from backups"
classification: public
---

## Overview

The ETCDBackup custom resource can be configured to exclude specific clusters from being backed up. This is particularly useful when you need to downscale or decommission clusters, as it prevents unnecessary backup operations.

__Note__: Scaling masters to zero will destroy the cluster, which cannot be restored anymore. It will need a backup to be restored.

## Prerequisites

- Access to the customer configuration repository
- Knowledge of the cluster IDs you want to exclude
- Basic understanding of YAML configuration

## Configuration Steps

1. Navigate to the customer configuration repository and locate the file:

   ```text
   installations/<INSTALLATION>/apps/etcd-backup-operator/configmap-values.yaml.patch
   ```

2. Add or update the `clusters_to_exclude` field in the configuration. This field accepts a regular expression pattern to match cluster IDs. For example:

   ```yaml
   clusters_to_exclude: '(wcp5x|ds746|0e77f|focw4|h2q4l)'
   ```

   This example excludes clusters with IDs: wcp5x, ds746, 0e77f, focw4, and h2q4l.

3. Commit and push the changes to the repository.

__Note__: Remember that some installations could be frozen and living in `vintage`. In that case, you must push to the frozen branch instead of `main`.


## Best Practices

- Use clear and descriptive commit messages when updating the configuration
- Document the reason for excluding specific clusters

## Troubleshooting

If backups are still being created for excluded clusters:

1. Verify the regular expression pattern is correct
2. Check if the configuration changes have been applied
3. Ensure the cluster IDs in the pattern match exactly with the actual cluster IDs
4. Check the etcd-backup-operator logs for any configuration-related errors

## Additional Resources

- [ETCDbackup Operator](https://github.com/giantswarm/etcd-backup-operator)
- [Regular Expression Syntax Reference](https://pkg.go.dev/regexp/syntax)