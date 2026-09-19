# Folder30: Terraform Meta-Arguments and Provider Aliases

This example demonstrates Terraform meta-arguments across AWS resources in two regions. It creates an S3 bucket in `us-east-1`, an IAM policy in `us-west-2`, and a DynamoDB table in `us-west-2`.

## What This Configuration Creates

- An S3 bucket named `soul-bucket-east` in `us-east-1`
- An IAM policy named `soulMetaPolicy` in `us-west-2`
- A DynamoDB table named `meta-argument-table` in `us-west-2`
- An output-free configuration whose resource relationships are managed through explicit dependencies

The IAM policy allows `s3:ListBucket` on all resources. It is a learning example and does not attach the policy to a user, group, or role.

## Files

- `main.tf`: Defines the S3 bucket, IAM policy, and DynamoDB table.
- `providers.tf`: Defines the default AWS provider in `us-east-1` and the `west` alias in `us-west-2`.
- `version.tf`: Defines the Terraform and AWS provider version constraints.

There are no input variables in this folder. Resource names, regions, and capacity values are defined directly in `main.tf` and `providers.tf`.

## Meta-Arguments Demonstrated

### Provider aliases

The default AWS provider targets `us-east-1`. Resources that specify `provider = aws.west` use the aliased provider in `us-west-2`:

```hcl
provider = aws.west
```

### `depends_on`

The IAM policy waits for the S3 bucket, and the DynamoDB table waits for the IAM policy:

```text
S3 bucket -> IAM policy -> DynamoDB table
```

These explicit dependencies demonstrate resource ordering when Terraform cannot infer the relationship from an attribute reference.

### `lifecycle`

The S3 bucket explicitly allows destruction with `prevent_destroy = false`.

The DynamoDB table uses:

- `create_before_destroy = true`, which creates a replacement before removing the old table when replacement is required
- `ignore_changes = [read_capacity]`, which prevents Terraform from planning changes caused only by that attribute

## Prerequisites

- Terraform `>= 1.15`
- AWS provider `>= 6.5`
- AWS credentials configured for the account
- Permission to create S3 buckets, IAM policies, and DynamoDB tables
- Access to both `us-east-1` and `us-west-2`

## Usage

Run the commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

To inspect the resources in state:

```bash
terraform state list
```

To remove the resources created by this example:

```bash
terraform destroy
```

## Important Notes

- S3 bucket names are globally unique. `soul-bucket-east` may already be used by another AWS account.
- IAM policies are global within an AWS account, even though this example assigns the `us-west-2` provider to the resource.
- DynamoDB tables are regional, so this table is created in `us-west-2`.
- The table uses provisioned capacity of 5 read and 5 write capacity units.
- `ignore_changes = [read_capacity]` means changes to read capacity in configuration are intentionally ignored by Terraform.
- The IAM policy is only created; it is not attached to an IAM principal.

## Troubleshooting

### `BucketAlreadyExists`

S3 bucket names must be unique across all AWS accounts. Change `bucket` in `main.tf` to a globally unique name, such as one containing a project or account suffix.

### `AccessDenied`

Verify that the active AWS identity can create S3 buckets, IAM policies, and DynamoDB tables. Also check whether an organization policy or service control policy restricts either region.

### The resource is created in the wrong region

Check the provider assignment. The S3 bucket uses the default provider in `us-east-1`, while the IAM policy and DynamoDB table use `provider = aws.west` in `us-west-2`. Run `terraform plan` and confirm the provider configuration before applying.

### Terraform reports that the `west` provider configuration is missing

Confirm that `providers.tf` contains an AWS provider with `alias = "west"` and that regional resources use the exact reference `aws.west`. Run `terraform init` after changing provider configuration.

### DynamoDB table creation fails

Confirm that DynamoDB is available in `us-west-2`, that the table name is not already managed by another Terraform state, and that the AWS identity has DynamoDB permissions. Provisioned tables also require valid read and write capacity values.

### Changes to `read_capacity` do not appear in the plan

This is intentional. The DynamoDB lifecycle rule contains `ignore_changes = [read_capacity]`. Remove that rule if Terraform should manage future read-capacity changes.

### Destroy does not behave as expected

The S3 bucket allows destruction, but S3 deletion can fail if the bucket contains objects. Empty the bucket first or add an appropriate object-management strategy. DynamoDB replacement behavior is also affected by `create_before_destroy`.

### `terraform validate` or `terraform plan` fails after editing

Run formatting and initialization again:

```bash
terraform fmt
terraform init
terraform validate
```

Then review the provider aliases and resource dependencies in `main.tf`.

## Lessons Learned

- Provider aliases allow one Terraform configuration to manage resources in multiple AWS regions.
- `depends_on` is useful when ordering is required but no direct attribute reference creates an implicit dependency.
- Lifecycle rules change how Terraform handles replacement, destruction, and drift.
- `ignore_changes` should be used deliberately because it stops Terraform from managing selected configuration changes.
- Regional resources must use the intended provider configuration, while some AWS services or objects have broader account-level scope.
- Explicit resource naming makes examples easy to understand but requires care with globally unique names.

## Conclusion

Folder30 provides a compact demonstration of Terraform meta-arguments, provider aliases, explicit dependencies, and lifecycle behavior. The configuration creates a clear dependency chain across resources in two AWS regions. Before using this pattern in a real project, replace hard-coded names and capacities with variables, use unique naming, review IAM permissions, and confirm that lifecycle behavior matches the desired operational and deletion policies.
