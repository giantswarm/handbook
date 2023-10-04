---
title: "How to trigger a CloudFormation stack reconciliation"
owner:
- https://github.com/orgs/giantswarm/teams/team-teddyfriends
confidentiality: public
---

## From the AWS Console

From time to time, it is necessary to trigger the reconciliation of a CloudFormation stack. This is usually needed in order to make our `aws-operator` reconcile the desired state with AWS. In order to trigger the reconciliation, follow these steps:

- Open the AWS Console and navigate to the CloudFormation section. Make sure you are in the correct region and account. If you are a Giant Swarm employee, you can use `opsctl open -i $MC -a cloudprovider` to open the account for the Management Cluster and `opsctl open -i $MC -a cloudprovider --workload-cluster $WC` to open the account for a Workload Cluster. Beware that you might need to run the command twice: one to log in to AWS, and one to move to the right account.
- Find the stack you want to reconcile and click on it. Then click on `Update`. <img src="../img/step1.jpg" width="1100" />
- Select `Edit in Designer` and click on `View in Designer`. <img src="../img/step2.jpg" width="1100" />
- Change the `Outputs.OperatorVersion` field by adding the `-trigger` suffix. Then, click on the "cloud" button on the top left. <img src="../img/step3.jpg" width="1100" />
- Click on `Next` for a few times. <img src="../img/step4.jpg" width="1100" />
- Tick on the `I acknowledge that AWS CloudFormation might create IAM resources.` checkbox and click on `Submit`. <img src="../img/step5.jpg" width="1100" />
- Wait for a few minutes. The stack's reconciliation will be done once the `OperatorVersion` output of the CloudFormation stack becomes the same as the `OperatorVersion` of the `aws-operator` running in the cluster. In other words: wait for the `-trigger` suffix to disappear from the `OperatorVersion` output.

