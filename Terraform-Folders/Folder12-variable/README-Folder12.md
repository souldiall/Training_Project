# Folder12: Terraform Variables

This folder demonstrates Terraform input variables, collection types, local values, and `for_each` with a map of objects.

## Configuration

The AWS provider is configured for the `us-east-1` region.

### Variables

Defined in `variable.tf`:

| Variable | Type | Purpose |
|---|---|---|
| `My_favorite_number` | `number` | Demonstrates a required numeric input. |
| `name` | `string` | Demonstrates a string variable with a default value. |
| `my_list` | `list(string)` | Demonstrates a list input and a local filter for odd values. |
| `my_number_of_instances` | unspecified | Previously used with the commented `count` example. |
| `my_instances` | `map(object(...))` | Defines the instance names, AMI IDs, and instance types used by `for_each`. |

The current values are stored in `terraform.tfvars`. The active configuration defines two instance objects:

```hcl
my_instances = {
	instance1 = {
		instance_type = "t2.micro"
		ami           = "ami1"
	}
	instance2 = {
		instance_type = "t3.micro"
		ami           = "ami2"
	}
}
```

`ami1` and `ami2` are example placeholders, not valid AWS AMI IDs. Replace them with AMI IDs that exist in `us-east-1` before running `terraform apply`.

### Resource creation

`main.tf` creates one `aws_instance` resource for each entry in `var.my_instances`:

```hcl
resource "aws_instance" "Instances" {
	for_each      = var.my_instances
	instance_type = each.value.instance_type
	ami           = each.value.ami
}
```

The commented code shows the alternative `count` approach. With `for_each`, each instance has a stable key such as `aws_instance.Instances["instance1"]`.

## Usage

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

To remove resources created by this example:

```bash
terraform destroy
```

AWS credentials must be configured through the AWS CLI, environment variables, or another supported credentials provider before planning or applying.

## Lessons Learned

- Input variables make configuration reusable without hard-coding values in resource blocks.
- Terraform validates values against the declared variable type. A variable declared as `number` must receive a numeric value, such as `10`, rather than arbitrary text.
- A `.tfvars` file is a convenient way to provide required variable values and avoid interactive prompts.
- `for_each` is useful when each resource needs a meaningful, stable key and structured values.
- A `map(object(...))` type documents the required attributes and types for every item in the map.
- AMI IDs are region-specific, so an AMI that works in one AWS region may not work in another.
- Outputs only appear when output blocks are enabled. The examples in `output.tf` are currently commented out.

## Troubleshooting

### Invalid value for input variable

Error:

```text
Unsuitable value for var.My_favorite_number: a number is required.
```

Ensure the value is numeric and is not commented out in `terraform.tfvars`:

```hcl
My_favorite_number = 10
```

If Terraform prompts interactively, enter a number only, for example `10`.

### Invalid AMI ID

Errors such as `InvalidAMIID.Malformed` or `InvalidAMIID.NotFound` mean that the AMI value is invalid or unavailable in `us-east-1`. Replace `ami1` and `ami2` with real AMI IDs from that region, or use a data source to find a current image.

### AWS credentials or permissions

Errors mentioning missing credentials or `UnauthorizedOperation` indicate that the active AWS identity is not configured or lacks permission. Verify the AWS CLI identity and permissions before applying:

```bash
aws sts get-caller-identity
```

### Variable is not being loaded

Terraform automatically loads files named `terraform.tfvars` and files ending in `.auto.tfvars`. For another filename, pass it explicitly:

```bash
terraform plan -var-file="custom.tfvars"
```

### State or provider issues

Run initialization again if the provider is missing or the lock file is out of date:

```bash
terraform init -upgrade
```

Do not edit `terraform.tfstate` manually. Use Terraform commands to inspect or change managed resources.

## Conclusion

Folder12 shows how Terraform variables can describe simple values and structured collections, then drive resource creation through `for_each`. The main practical requirements are to provide values with the correct types, use AMI IDs valid for the configured region, and review the plan before creating AWS resources.
