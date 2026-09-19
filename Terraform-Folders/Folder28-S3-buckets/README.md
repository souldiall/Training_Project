# Folder28: S3 Buckets with `for_each`

This example creates one Amazon S3 bucket for each environment in the `envs` variable. The default environments are `dev`, `staging`, and `prod`.

## What This Configuration Creates

For every environment, Terraform creates:

- An S3 bucket named `soul-<environment>-bucket`
- S3 bucket versioning enabled
- Bucket ownership controls using `BucketOwnerPreferred`
- Public access settings that allow the public-read policy
- A bucket policy allowing anyone to read objects
- A `README.txt` object containing environment-specific HTML content

With the default values, the bucket names are:

- `soul-dev-bucket`
- `soul-staging-bucket`
- `soul-prod-bucket`

## Files

- `provider.tf`: Configures AWS in the `us-east-1` region.
- `version.tf`: Defines the Terraform and AWS provider versions.
- `variables.tf`: Defines the environment set.
- `locals.tf`: Builds bucket names and the content for each object.
- `main.tf`: Creates the S3 buckets and related resources.

## Prerequisites

- Terraform `>= 1.15`
- AWS credentials configured for the terminal or environment
- Permission to create and manage S3 buckets, policies, objects, and versioning
- Globally unique S3 bucket names

## Usage

From this directory, initialize Terraform:

```bash
terraform init
```

Review the resources Terraform will create:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

To remove the resources created by this example:

```bash
terraform destroy
```

## Changing Environments

The `envs` variable is a set of strings. It can be overridden with a `.tfvars` file or on the command line:

```hcl
envs = ["dev", "qa"]
```

or:

```bash
terraform plan -var='envs=["dev","qa"]'
```

Each environment must have a matching entry in `local.readme_content`. If a new environment is added without corresponding content, Terraform will fail when evaluating the object content expression.

## Important Security Note

This example deliberately disables S3 public-access blocking and attaches a public-read policy. Anyone on the internet can read objects stored in these buckets. Do not use this configuration for private data or production workloads without reviewing the access model.

For a private bucket, enable the public-access blocking settings and remove the public-read bucket policy.

## Useful Commands

List the resources in Terraform state:

```bash
terraform state list
```

Show a specific bucket:

```bash
terraform state show 'aws_s3_bucket.buckets["dev"]'
```

Format the Terraform files:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

## Troubleshooting

### `BucketAlreadyExists` or a bucket name is unavailable

S3 bucket names are globally unique across AWS. Change the naming expression in `locals.tf` to include a unique suffix, such as an account identifier or project name, then run `terraform plan` again.

### AWS credentials or permission errors

Confirm that the AWS CLI is authenticated and that the selected identity has permissions for S3 bucket creation, versioning, policies, ownership controls, and object uploads. Also verify that the configured region is correct.

### `AccessDenied` while applying the bucket policy

Check whether an AWS Organizations policy, account-level S3 Block Public Access setting, or security control prevents public policies. This example requires public access settings to permit the public-read policy.

### An environment is missing from `readme_content`

If `envs` includes a value such as `qa`, add a `qa` entry to `local.readme_content` in `locals.tf`. The map key must exactly match the environment name.

### Terraform prompts for a variable

Provide a value in a `.tfvars` file or pass it with `-var`. For example:

```bash
terraform plan -var='envs=["dev","staging","prod"]'
```

### The object appears as HTML instead of plain text

The object key is `README.txt`, but its `content_type` is set to `text/html`. Rename the key to `README.html` for an HTML object, or change `content_type` to `text/plain` if the object should be treated as text.

## Lessons Learned

- `for_each` is useful for creating one related group of resources per environment.
- Using the same map or set keys across resources keeps dependencies predictable.
- Locals can centralize derived names and environment-specific content.
- S3 bucket names must be globally unique, not just unique within an AWS account.
- Public access configuration should be treated as a deliberate security decision.
- Versioning helps preserve previous object versions and supports recovery from accidental overwrites.

## Conclusion

This example demonstrates how Terraform can manage repeatable, environment-specific S3 infrastructure from a small configuration. The `for_each` pattern keeps each bucket and its supporting resources associated with the same environment key. Before using this pattern in a real project, make bucket names unique, decide whether buckets should be public or private, and add outputs or monitoring appropriate to the workload.
