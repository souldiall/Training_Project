# Project:
Multi-OS-Template-CloudFormation.json
## Purpose:
Deploy a single EC2 web server instance whose OS — Windows Server, Amazon Linux, or Ubuntu Server — is selected at deploy time via a single CloudFormation template with OS-based conditions. Deploying the stack three times (once per OS value) produces one instance of each type.

## Overview
This project demonstrates how to provision a web server on any of three operating systems from one reusable CloudFormation template, without maintaining separate templates per OS.
The template uses:

- An `OS` parameter to select the operating system
- Conditions to determine which UserData script and AMI to use
- `Fn::If` logic to dynamically switch between Windows, Amazon Linux, and Ubuntu
- A `Mappings` table (`RegionMap`) holding the correct AMI ID per region, per OS
- A single `AWS::EC2::Instance` resource (`WebServer`) whose properties change based on the selected OS
- A security group that always opens HTTP (80), and conditionally opens RDP (3389) for Windows or SSH (22) for Linux

This pattern is essential for multi-OS automation and reusable infrastructure — the same template file can stand up a Windows, Amazon Linux, or Ubuntu web server just by changing the `OS` parameter (and re-running the stack).

## Project Structure
```
Multi-OS-Template-CloudFormation.json
README.md
```

### How the Template Works

**1️⃣ OS Parameter**
The `OS` parameter accepts one of three values:

- `Windows`
- `AmazonLinux`
- `Ubuntu`

This single value drives AMI selection, UserData, and part of the security group configuration for that deployment.

**2️⃣ Conditions**
The template defines three conditions, each comparing the `OS` parameter to a fixed value:

- `IsWindows` → `Fn::Equals: [OS, "Windows"]`
- `IsAmazonLinux` → `Fn::Equals: [OS, "AmazonLinux"]`
- `IsUbuntu` → `Fn::Equals: [OS, "Ubuntu"]`

These conditions are used inside `Fn::If` blocks in the security group and the `WebServer` resource's `UserData`.

**3️⃣ AMI Selection**
AMIs are **not** looked up dynamically — they're hardcoded per region, per OS in the `RegionMap` mapping, and selected with `Fn::FindInMap: [RegionMap, SelectedRegion, OS]`:

| OS | AMI Source |
|---|---|
| Windows | Hardcoded Windows Server AMI ID per region (in `RegionMap`) |
| Amazon Linux | Hardcoded Amazon Linux 2 AMI ID per region (in `RegionMap`) |
| Ubuntu | Hardcoded Ubuntu AMI ID per region (in `RegionMap`) |

`RegionMap` currently covers `us-east-1`, `us-east-2`, `us-west-1`, and `us-west-2`. The `SelectedRegion` parameter — not the AWS pseudo-parameter `AWS::Region` — is what picks the row, so it must match the region you're actually deploying into.

**4️⃣ UserData Logic**
A single `WebServer` resource's `UserData` branches by OS using nested `Fn::If`:

| OS | Web Server Installed | UserData Type |
|---|---|---|
| Windows | IIS (`Install-WindowsFeature -name Web-Server`) | PowerShell |
| Amazon Linux | httpd (via `yum`) | Bash |
| Ubuntu | apache2 (via `apt`) | Bash |

Each branch also writes the `CustomHtml` parameter value into the web root (`C:\inetpub\wwwroot\index.html` for Windows, `/var/www/html/index.html` for Amazon Linux/Ubuntu) using `Fn::Sub`.

### EC2 Instance Created
The template defines **one** EC2 resource, `WebServer`, whose behavior depends entirely on the `OS` parameter passed at deploy time:

| Parameter Value | OS Deployed | Web Server |
|---|---|---|
| `Windows` | Windows Server | IIS |
| `AmazonLinux` | Amazon Linux 2 | httpd |
| `Ubuntu` | Ubuntu Server | apache2 |

To end up with all three OSes running simultaneously (as separate instances), deploy this template as **three separate stacks**, each with a different `OS` value and, ideally, a distinct `InstanceName`.

Each instance also gets these tags: `Name` (from `InstanceName`), `Environment: Dev`, `Owner: Souleymane`, and `OS` (from the `OS` parameter).

### Security Group
A single `WebSecurityGroup` is created per stack:

- Port **80** (HTTP) is always open to `0.0.0.0/0`
- Port **3389** (RDP) is opened to `0.0.0.0/0` only if `IsWindows` is true
- Port **22** (SSH) is opened to `0.0.0.0/0` otherwise (Amazon Linux/Ubuntu)

### Deployment Instructions
1. Upload the Template
   Upload `Multi-OS-Template-CloudFormation.json` directly into the CloudFormation console.

2. Create the Stack
   In the AWS Console:
   - Go to **CloudFormation**
   - Click **Create stack**
   - Choose **Upload a template file**
   - Select `Multi-OS-Template-CloudFormation.json`
   - Click **Next**

3. Provide Parameters
   You will be prompted for:
   - `VpcId`
   - `SubnetId`
   - `KeyName`
   - `CustomHtml`
   - `InstanceName`
   - `SelectedRegion` (must match the region you're deploying into — one of `us-east-1`, `us-east-2`, `us-west-1`, `us-west-2`)
   - `AvailabilityZone`
   - `InstanceType` (`t2.micro`, `t3.micro`, or `t3.small`)
   - `OS` (`Windows`, `AmazonLinux`, or `Ubuntu`) — this is what determines which OS this particular stack deploys

4. Deploy
   Click **Create Stack**. CloudFormation will:
   - Evaluate the OS conditions
   - Look up the correct AMI from `RegionMap` using `SelectedRegion` and `OS`
   - Apply the correct UserData script
   - Launch the security group and the single `WebServer` instance

5. Repeat for Each OS
   To get a Windows, an Amazon Linux, and an Ubuntu instance, repeat steps 2–4 three times, changing only the `OS` parameter (and `InstanceName`, to keep them distinguishable) each time.

### Testing the Deployment
For each stack you deploy, check the `PublicIP` output value and open it in a browser:

```
http://<WebServer-Public-IP>
```

It should display the HTML you passed in via the `CustomHtml` parameter. Note: this template does not allocate an Elastic IP, so the public IP shown depends on the subnet's auto-assign public IP setting being enabled.

## Key CloudFormation Features Used
- Parameters
- Mappings (`RegionMap`)
- Conditions
- `Fn::Equals`
- `Fn::If`
- `Fn::Sub`
- `Fn::Base64`
- `Fn::FindInMap`
- `Fn::GetAtt` (for the `PublicIP` output)
- EC2 UserData automation

This template is a strong foundation for multi-OS automation and reusable infrastructure patterns.

## Conclusion
This project shows that a single, well-structured CloudFormation template can provision infrastructure for multiple operating systems without maintaining separate templates per OS. By combining a parameterized `OS` value, `Conditions`, a `Mappings` table for AMIs, and `Fn::If`-driven `UserData`, the template centralizes every OS-specific decision into one file — while each deployment still produces a single, purpose-built instance.

Because the OS is chosen per-stack rather than per-instance, the template trades "one stack, three instances" for "one template, three possible stacks" — a simpler, more predictable design that's easy to extend (e.g. adding a fourth OS, or a fourth region to `RegionMap`) without restructuring the resources themselves.

## Lessons Learned
- **One resource, three OSes.** Rather than defining three separate `AWS::EC2::Instance` resources, this template defines one `WebServer` resource whose `ImageId` and `UserData` both branch on the `OS` parameter via `Fn::If`. This keeps the template compact, but it also means one stack only ever creates one instance — getting all three OSes running requires three separate stack deployments, not three resources in one stack.
- **Mappings vs. SSM Parameter Store lookups are a real design choice.** This template hardcodes AMI IDs per region in `RegionMap`, rather than using an SSM Parameter Store lookup (e.g. for the "latest" Amazon Linux AMI). That makes deployments perfectly reproducible, but it also means the AMI IDs will eventually go stale and need manual updates as AWS deprecates old AMIs.
- **`SelectedRegion` is a parameter, not the actual deploy region.** `Fn::FindInMap` uses the `SelectedRegion` parameter value to pick a row from `RegionMap` — it does **not** automatically detect the region the stack is being deployed into (that would be the `AWS::Region` pseudo-parameter). If `SelectedRegion` doesn't match where you're actually deploying, you can end up with an AMI ID that isn't valid in that region.
- **`AvailabilityZone` is defined but unused.** The template declares an `AvailabilityZone` parameter, but no resource in the template currently references it. It's harmless as-is, but worth removing or wiring into a `Placement` block if AZ pinning is actually needed.
- **UserData syntax is OS-dependent and easy to break.** PowerShell (Windows) and Bash (Amazon Linux/Ubuntu) have very different syntax and quoting rules. Nesting them inside one `Fn::If` block inside `Fn::Base64` makes it easy to introduce a subtle syntax error in one branch that only surfaces when you deploy with that specific `OS` value.
- **`Fn::Sub` + raw HTML is fragile.** `CustomHtml` is injected directly into the UserData script with `Fn::Sub` (e.g. `echo "${CustomHtml}" > /var/www/html/index.html`). If the HTML contains double quotes, `$` characters, or newlines, it can break the shell/PowerShell command it's embedded in — this only supports very simple, single-line HTML strings.
- **The security group's conditional port is a nice touch, but still wide open.** Using `Fn::If` to open RDP for Windows and SSH for Linux (instead of opening both always) is a good practice, but both are still scoped to `0.0.0.0/0` — fine for a quick demo, risky for anything left running.
- **Testing one OS branch at a time speeds up development.** Since AMI and UserData logic are all conditional on one `OS` parameter, it's fast to iterate: deploy with `OS=Ubuntu`, fix issues, then redeploy with `OS=AmazonLinux`, then `OS=Windows`, rather than trying to validate all three UserData branches at once.

## Troubleshooting

### Stack fails to create / rolls back immediately
- Check the **Events** tab in the CloudFormation console for the first `CREATE_FAILED` resource — later failures are usually rollback noise from dependent resources.
- Common causes specific to this template:
  - `SelectedRegion` doesn't match the AMI IDs in `RegionMap` for the region you're actually deploying into.
  - `KeyName` doesn't exist as a KeyPair in that region.
  - `VpcId` / `SubnetId` aren't in the same VPC, or the subnet doesn't belong to the given VPC.

### `Fn::FindInMap` fails / "Invalid AMI ID" errors
- This template only defines AMI mappings for `us-east-1`, `us-east-2`, `us-west-1`, and `us-west-2`. Deploying with a `SelectedRegion` outside this list (or actually deploying the stack into a different region than `SelectedRegion` says) will either fail template validation or produce an invalid AMI reference.
- Remember: AMI IDs are region-specific and go stale over time. If the AMI ID in `RegionMap` for your region/OS combination has been deprecated by AWS, the instance launch will fail — you'll need to update `RegionMap` with a current AMI ID.

### Instance launches but the website isn't reachable
- Confirm the subnet has **auto-assign public IP** enabled — this template does not allocate an Elastic IP, so if the subnet doesn't hand out a public IP automatically, the `PublicIP` output may be empty or unreachable.
- Confirm you're testing on port 80 — the security group only opens HTTP (80) plus RDP/SSH depending on OS; no other ports are open.
- Give the instance a minute or two — UserData execution takes longer on Windows (installing the IIS feature) than on Linux.

### Windows instance UserData doesn't seem to run
- Confirm the UserData actually starts with `<powershell>` and ends with `</powershell>` — this template's `Fn::If` branch for `IsWindows` should render exactly that; a manual edit that breaks the tags will cause EC2 to silently skip it.
- RDP into the instance (port 3389 is open for `IsWindows`) and check `C:\ProgramData\Amazon\EC2Launch\log\agent.log` (or `EC2Launchv2` logs, depending on AMI) for UserData execution errors.
- Confirm `Install-WindowsFeature -name Web-Server` actually completed — this also starts the IIS service by default, so if the page isn't loading, check `Get-Service W3SVC` from a PowerShell prompt on the instance.

### Amazon Linux or Ubuntu instance shows nothing / connection refused
- SSH in (port 22 is open for non-Windows OSes) and check `/var/log/cloud-init-output.log` for errors from the Bash UserData script — this is the fastest way to see exactly where it failed.
- Amazon Linux: confirm httpd is installed and running — `sudo systemctl status httpd`. The script uses `yum`, so this will fail on non-Amazon-Linux-2 AMIs (e.g. AL2023, which uses `dnf`) if the AMI in `RegionMap` for that OS/region is ever changed.
- Ubuntu: confirm apache2 is installed and running — `sudo systemctl status apache2`. Note the script runs `apt update -y` and `apt install -y apache2` without a `restart`/`enable` for the service on first install in some Ubuntu AMI versions — if the page doesn't load, manually run `sudo systemctl restart apache2` and check again.

### `CustomHtml` content isn't showing up correctly, or the instance fails at the `echo`/`Set-Content` step
- The `CustomHtml` parameter is embedded directly into the UserData via `Fn::Sub` with no escaping. Avoid double quotes (`"`), `$` characters, or multi-line content in this parameter — any of these can break the surrounding `echo "..."` (Linux) or `Set-Content -Value "..."` (Windows) command.
- If you need multi-line or complex HTML, consider base64-encoding it outside the template and decoding it inside UserData instead of passing raw HTML through `Fn::Sub`.

### `Fn::If` / Condition validation errors
- All three conditions (`IsWindows`, `IsAmazonLinux`, `IsUbuntu`) must exist exactly as referenced — a typo in a condition name inside an `Fn::If` fails template validation before the stack even starts.
- `Fn::Equals` comparisons against `OS` are case-sensitive — the parameter's `AllowedValues` (`Ubuntu`, `AmazonLinux`, `Windows`) must be passed exactly as written; CloudFormation's own parameter validation will reject anything not in that list, but it's a common source of confusion if you're scripting stack creation via the CLI.

### Only one instance appears after deployment, expected three
- This is expected behavior, not a bug: the template's `WebServer` resource is singular and branches by the `OS` parameter. To get Windows, Amazon Linux, and Ubuntu instances simultaneously, deploy this template as three separate CloudFormation stacks, each with a different `OS` value.
