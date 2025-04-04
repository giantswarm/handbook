---
title: "Configure ETCDbackup Exclusions"
owner:
- https://github.com/orgs/giantswarm/teams/team-planeteers
component:
  - etcd-backup-operator
description: "How to configure ETCDbackup custom resource to exclude specific clusters from backups"
classification: public
---

## Overview

The ETCDbackup custom resource can be configured to exclude specific clusters from being backed up. This is particularly useful when you need to downscale or decommission clusters, as it prevents unnecessary backup operations.

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
   clusters_to_exclude: '(wcp4x|dc746|0d77f|aocw4|hnq40)'
   ```

   This example excludes clusters with IDs: wcp4x, dc746, 0d77f, aocw4, and hnq40.

3. Commit and push the changes to the repository.

## Best Practices

- Use clear and descriptive commit messages when updating the configuration
- Document the reason for excluding specific clusters
- Regularly review the list of excluded clusters to ensure they are still relevant
- Test the configuration in a non-production environment first if possible

## Troubleshooting

If backups are still being created for excluded clusters:

1. Verify the regular expression pattern is correct
2. Check if the configuration changes have been applied
3. Ensure the cluster IDs in the pattern match exactly with the actual cluster IDs
4. Check the etcd-backup-operator logs for any configuration-related errors

## Additional Resources

- [ETCDbackup Operator](https://github.com/giantswarm/etcd-backup-operator)
- [Regular Expression Syntax Reference](https://docs.python.org/3/library/re.html#regular-expression-syntax)