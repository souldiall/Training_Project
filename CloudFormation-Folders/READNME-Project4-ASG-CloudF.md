# Auto Scaling Group (ASG) Deployment with AWS CloudFormation

## Overview

This project provisions an **Amazon EC2 Auto Scaling Group (ASG)** using **AWS CloudFormation** as Infrastructure as Code (IaC). The template defines and deploys a scalable, self-healing compute layer that automatically adjusts the number of EC2 instances based on demand, ensuring high availability and cost efficiency.

- **Provider:** AWS
- **IaC Tool:** AWS CloudFormation
- **Author:** Souleymane Diallo
- **Student ID:** UCT4

---

## Architecture Summary

The CloudFormation stack typically provisions the following resources:

- **Launch Template / Launch Configuration** — defines the AMI, instance type, key pair, security groups, and user data used to launch EC2 instances.
- **Auto Scaling Group (ASG)** — manages the desired, minimum, and maximum number of EC2 instances across one or more Availability Zones.
- **Scaling Policies** — define how the ASG scales in or out (e.g., based on CPU utilization or a target tracking metric).
- **CloudWatch Alarms** — trigger scaling policies when defined thresholds are breached.
- **(Optional) Application Load Balancer (ALB) / Target Group** — distributes incoming traffic across healthy instances in the ASG.
- **Security Groups** — control inbound/outbound traffic to the instances.
- **IAM Role / Instance Profile** — grants EC2 instances the permissions needed to operate.

---

## Prerequisites

Before deploying this stack, ensure you have:

1. An active **AWS account** with sufficient IAM permissions to create EC2, Auto Scaling, CloudWatch, and IAM resources.
2. Access to the **AWS Management Console** with a user/role that has permissions to create CloudFormation stacks and their underlying resources.
3. An existing **VPC**, **subnets**, and (if applicable) a **key pair** for SSH access.
4. Basic familiarity with **YAML/JSON** syntax, since CloudFormation templates are written in either format.

---

## Deployment Instructions (AWS Management Console)

### 1. Open CloudFormation

Sign in to the **AWS Management Console**, then navigate to **Services → CloudFormation**.

### 2. Create a new stack

- Click **Create stack** → **With new resources (standard)**.
- Under **Prerequisite - Prepare template**, select **Template is ready**.
- Under **Specify template**, select **Upload a template file**, then click **Choose file** and select your `asg-template.yaml` file.
- Click **Next**.

### 3. Specify stack details

- Enter a **Stack name** (e.g., `asg-stack`).
- Fill in any required **Parameters** (e.g., KeyName, InstanceType, VPC ID, Subnet IDs, Min/Max/Desired capacity).
- Click **Next**.

### 4. Configure stack options

- (Optional) Add **Tags** to help identify and organize the stack's resources.
- (Optional) Set an **IAM role** for CloudFormation to use when creating resources.
- Leave the remaining defaults unless your setup requires otherwise.
- Click **Next**.

### 5. Review and create

- Review all settings and parameters.
- If the template creates IAM resources, check the acknowledgment box:
  *"I acknowledge that AWS CloudFormation might create IAM resources."*
- Click **Submit** (or **Create stack**).

### 6. Monitor stack creation

- On the stack's **Events** tab, watch the resources being created in real time.
- The stack status will change to **CREATE_COMPLETE** once all resources (Launch Template, Auto Scaling Group, Scaling Policies, CloudWatch Alarms, etc.) have been successfully provisioned.
- If creation fails, the status will show **ROLLBACK_COMPLETE** — check the Events tab for the specific error.

### 7. Update the stack (after making changes)

- Select the stack from the **Stacks** list.
- Click **Update**.
- Choose **Replace current template**, upload the revised `asg-template.yaml`, and click through **Next** on each step.
- Review the **Change set** preview, then click **Update stack**.

### 8. Delete the stack (cleanup)

- Select the stack from the **Stacks** list.
- Click **Delete**, then confirm the deletion.
- Monitor the **Events** tab until the stack status changes to **DELETE_COMPLETE**.

---

## Verifying the Deployment

- Check the **EC2 Console → Auto Scaling Groups** to confirm the group was created with the expected desired/min/max capacity.
- Check the **EC2 Console → Instances** to confirm instances are launching and passing health checks.
- If a Load Balancer is attached, confirm the **Target Group** shows healthy targets.
- Review **CloudWatch Alarms** to confirm scaling policies are correctly linked to metrics.

---

## Conclusion

This project demonstrates how AWS CloudFormation can be used to provision and manage an Auto Scaling Group in a repeatable, version-controlled, and automated manner. By defining infrastructure as code, the deployment becomes consistent across environments, easier to audit, and simple to tear down or redeploy. The ASG ensures that the application layer can scale elastically in response to real-world traffic patterns, improving both availability and cost efficiency compared to manually managed EC2 fleets.
Implementing an Auto Scaling Group (ASG) in CloudFormation gives you a fully automated, self‑healing, and scalable EC2 architecture. By defining your infrastructure as code, you ensure consistency, repeatability, and easier long‑term maintenance. When combined with a Launch Template, an Application Load Balancer, and proper health checks, your ASG becomes capable of handling variable workloads while maintaining high availability across multiple Availability Zones.

This approach also sets the foundation for more advanced patterns such as blue/green deployments, immutable infrastructure, and automated scaling based on application‑level metrics. In short, CloudFormation allows you to build a production‑ready scaling system that is predictable, secure, and easy to evolve.
---

## Lessons Learned

- **Infrastructure as Code saves time and reduces errors.** Defining the ASG in CloudFormation eliminated manual, error-prone console configuration and made the environment reproducible.
- **IAM permissions matter early.** Many early deployment failures were tied to insufficient permissions rather than template errors, reinforcing the importance of least-privilege IAM roles and correctly checking the IAM acknowledgment box during stack creation.
- **Health checks directly affect ASG behavior.** Misconfigured health check grace periods or health check types (EC2 vs ELB) can cause instances to be terminated and relaunched in a loop.
- **Parameterization improves reusability.** Using CloudFormation parameters (e.g., instance type, AMI ID, subnet IDs) instead of hardcoded values made the template reusable across dev/staging/production environments.
- **Rollback behavior needs to be understood.** CloudFormation automatically rolls back failed stack creations by default, which can hide the true root cause of a failure unless events are reviewed promptly.
- **Scaling policies need real metrics to be meaningful.** Testing scaling policies required generating actual load (or manually adjusting desired capacity) to validate that CloudWatch alarms correctly triggered scale-in/scale-out actions.

---

## Troubleshooting

| Issue | Likely Cause | Resolution |
|---|---|---|
| Stack creation fails with `ROLLBACK_COMPLETE` | An error occurred during resource creation | Check **CloudFormation → Events tab** for the specific failing resource and error message; delete the stack and redeploy after fixing the template |
| `Insufficient permissions` error | The IAM user/role deploying the stack lacks required permissions | Attach the necessary IAM policies to your Console user/role, and make sure you check the **IAM resources acknowledgment** box on the Review step |
| Instances launch but fail health checks | User data script errors, misconfigured security groups, or wrong health check target | Use **EC2 Console → Instances → Connect** (or check the system log under **Actions → Monitor and troubleshoot → Get system log**) to debug the user data script; verify the security group allows required ports |
| ASG shows 0 running instances | Min/desired capacity set to 0, or subnet/AZ misconfiguration | In the **EC2 Console → Auto Scaling Groups**, edit the group and verify `MinSize`, `DesiredCapacity`, and that the selected subnets belong to AZs supported by the chosen instance type |
| Scaling policy never triggers | CloudWatch alarm threshold not being reached, or alarm not linked to the correct ASG | In the **CloudWatch Console → Alarms**, confirm the alarm's metric, namespace, and dimensions match the ASG; manually adjust desired capacity or generate load to test |
| `Template format error` on upload | Invalid YAML/JSON syntax (indentation, missing colons, etc.) | On the **Create stack** page, use **Template is ready → Upload a template file**, then click **View in Designer** to visually validate the template before proceeding |
| Stack stuck in `UPDATE_IN_PROGRESS` | A resource is waiting on a dependency or manual intervention | Check the **Events** tab for the resource that is pending; in rare cases, click **Update → Cancel update** from the stack actions menu if it is truly stuck |
| Cannot delete stack (`DELETE_FAILED`) | A resource has dependent objects (e.g., ENI still attached) | Manually detach/delete the blocking resource in its respective console (e.g., EC2 → Network Interfaces), then retry **Delete** on the stack |

---

## Author

**Souleymane Diallo**
Student ID: **UCT4**