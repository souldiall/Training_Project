# Folder25: Importing an Existing Application Load Balancer

This example demonstrates how Terraform can import an existing AWS Application Load Balancer and manage listener rules for it. The configuration targets an ALB in `us-east-1`, reads an existing HTTP listener, and creates two fixed-response path rules.

## What This Configuration Manages

- An existing Application Load Balancer imported into Terraform state
- An existing HTTP listener read with a data source
- A fixed-response rule for `/ALB`
- A fixed-response rule for `/terraform`

The responses are:

- `/ALB`: `Welcome to Mr Valery Class`
- `/terraform`: `Welcome to Mr Staline Class`

## Files

- `main.tf`: Declares the existing ALB resource that Terraform will manage.
- `import.tf`: Contains the declarative import block with the ALB ARN.
- `data.tf`: Reads the existing listener and defines the two listener rules.
- `provider.tf`: Configures AWS in `us-east-1`.
- `version.tf`: Defines Terraform and AWS provider version constraints.

## Important Configuration Notes

This folder contains account-specific values:

- ALB ARN
- Listener ARN
- Subnet IDs
- AWS account ID in the ARNs

Replace these values before using the configuration in another AWS account, region, or environment. The existing ALB and listener must already exist and the configured AWS identity must be allowed to read and modify them.

The `aws_lb` resource is intentionally minimal. After import, run `terraform plan` and compare the imported remote settings with the resource configuration. Add important settings such as security groups, access logs, deletion protection, or idle timeout if Terraform should manage them explicitly.

## Prerequisites

- Terraform `>= 1.15`
- AWS provider `>= 6`
- An existing Application Load Balancer in `us-east-1`
- An existing HTTP listener matching the listener ARN in `data.tf`
- AWS credentials with permission to describe, import, and modify the ALB and listener rules
- The AWS account ID, ALB ARN, listener ARN, and subnet IDs for the target resources

## Import Workflow

Initialize the working directory:

```bash
terraform init
```

Review the configuration and validate the syntax:

```bash
terraform fmt
terraform validate
```

Preview the import and planned changes:

```bash
terraform plan
```

Apply the configuration. Terraform will process the `import` block and place the existing ALB into state:

```bash
terraform apply
```

Confirm that the ALB is tracked:

```bash
terraform state list
terraform state show 'aws_lb.ALB-Lab-ALB-rsDJ97ISgBH1'
```

After the first import, run another plan. The goal is to review and intentionally resolve any differences between the minimal Terraform declaration and the existing ALB configuration.

## Testing the Listener Rules

Use the ALB DNS name from the AWS console or state, then test the paths:

```bash
curl http://<alb-dns-name>/ALB
curl http://<alb-dns-name>/terraform
```

The listener rules return fixed text directly from the ALB. They do not forward requests to target groups.

## Declarative Import Versus CLI Import

This example uses a Terraform import block:

```hcl
import {
  to = aws_lb.example
  id = "<load-balancer-arn>"
}
```

This keeps the import instruction in the configuration and allows it to be reviewed with the rest of the code. A one-time CLI import is also possible:

```bash
terraform import aws_lb.example <load-balancer-arn>
```

When using the CLI form, the resource must already be declared in the configuration, and the import command must be run from the correct Terraform working directory.

## Security Considerations

Listener rules return public HTTP responses if the ALB is internet-facing. Use HTTPS and an ACM certificate for real applications, and restrict the ALB security group to the intended source networks where appropriate.

Avoid committing reusable documentation or configuration with account-specific identifiers unless the repository is private and the values are intentionally managed. Use variables or environment-specific files for portable configurations.

Importing a resource does not automatically make its full security posture part of Terraform management. Review security groups, listeners, certificates, access logs, deletion protection, and routing separately.

## Troubleshooting

### `Cannot import non-existent remote object`

Verify that the ALB ARN is correct, the resource exists in `us-east-1`, and the configured AWS credentials belong to the expected account. Confirm the ARN with the AWS CLI or the EC2 console.

### The listener data source cannot be found

Check that the listener ARN in `data.tf` belongs to the imported ALB and that the listener still exists. Listener ARNs are resource-specific and cannot be reused across load balancers.

### Terraform wants to replace the imported ALB

The resource declaration in `main.tf` is minimal and may not describe all settings of the existing ALB. Review the plan carefully and add matching arguments, or use lifecycle settings only when ignoring a difference is intentional. Do not apply a replacement plan without understanding its impact.

### Terraform reports subnet or region errors

Confirm that the subnet IDs belong to `us-east-1` and are valid for the imported ALB. Subnets and load balancers are regional resources.

### Listener rule priority is already in use

Listener rule priorities must be unique for a listener. Change priority `4` or `5` to an unused value after checking the existing listener rules.

### The path rule does not match

The current rules match exactly `/ALB` and `/terraform`. Add wildcard patterns such as `/ALB/*` or `/terraform/*` if child paths should also match.

### The rule is not visible after apply

Check the listener ARN, rule priority, and Terraform state. Confirm the AWS identity has permission to create listener rules and that the rule was not created in a different region or account.

### Terraform tries to remove the import on every run

Ensure the imported resource address in the `import` block exactly matches the resource address in `main.tf`. Run `terraform state list` and compare the address character for character.

### Destroy or removal behavior is unexpected

Removing an import block does not automatically delete the remote ALB. Review the plan before destroying resources. If the ALB should remain but no longer be managed, use `terraform state rm` carefully after confirming the desired ownership model.

## Lessons Learned

- Terraform can adopt existing AWS resources without recreating them.
- Importing a resource into state is separate from fully describing its configuration in code.
- Data sources are useful for reading existing resources such as listeners.
- Listener rule priorities must be unique within a listener.
- Account IDs, ARNs, subnet IDs, and regions must match the target environment.
- A post-import plan is essential for detecting drift and incomplete resource configuration.
- Fixed-response listener rules return content from the ALB and do not require backend targets.

## Conclusion

Folder25 demonstrates a practical Terraform import workflow for an existing Application Load Balancer. It combines a declarative import block, an existing listener data source, and path-based fixed-response rules. The main lesson is that importing state is only the first step: the resulting plan must be reviewed carefully, the resource configuration should be completed intentionally, and account-specific identifiers should be made portable before reusing the pattern elsewhere.
