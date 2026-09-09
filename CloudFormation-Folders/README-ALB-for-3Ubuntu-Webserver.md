# Project:
Application Load Balancer for 3 Ubuntu Web Servers
## Overview
This project deploys a complete AWS environment using CloudFormation to demonstrate load balancing across three Ubuntu EC2 web servers.
The stack includes networking, security, compute, and an Application Load Balancer (ALB) that distributes HTTP traffic evenly across all three instances.

Each EC2 instance runs Apache2 and serves a unique HTML message:

Server 1 – Load Balancer Test

Server 2 – Load Balancer Test

Server 3 – Load Balancer Test

Refreshing the ALB DNS in your browser cycles through these messages, confirming round‑robin load balancing.

## Architecture Diagram (Conceptual)
Code
                    Internet
                        |
                +----------------+
                |     ALB        |
                |  (HTTP : 80)   |
                +----------------+
                   /     |     \
                  /      |      \
                 v       v       v
        +-----------+ +-----------+ +-----------+
        | EC2 #1    | | EC2 #2    | | EC2 #3    |
        | Apache2   | | Apache2   | | Apache2   |
        +-----------+ +-----------+ +-----------+
## Resources Created
Networking
VPC (10.0.0.0/16)

Internet Gateway

Public Route Table + Default Route

Public Subnet 1 (10.0.1.0/24)

Public Subnet 2 (10.0.2.0/24)

Security
ALBSG — Allows HTTP (80) from anywhere

InstanceSG — Allows HTTP (80) only from ALB SG

Compute
EC2Instance1 (Ubuntu, Apache2, AZ1)

EC2Instance2 (Ubuntu, Apache2, AZ2)

EC2Instance3 (Ubuntu, Apache2, AZ1)

Load Balancing
Application Load Balancer (ALB)

Target Group (HTTP:80)

Listener (HTTP:80 → forward → TargetGroup)

3 Target Attachments

### Outputs
ALBDNS — DNS name of the ALB

### UserData (Apache2 Setup)
Each EC2 instance installs Apache2 and writes a unique message:

Example from EC2Instance1:

bash
#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
echo "Server 1 - Load Balancer Test" > /var/www/html/index.html
Instances 2 and 3 follow the same pattern with their respective messages.

## Deployment Instructions
1. Upload Template
Go to:

AWS Console → CloudFormation → Create Stack → Upload a template file

Select:

ALB-for-3-Ubuntu-WebServer-TemplateCloudFormation.json

2. Configure Parameters
Parameter	Default	Description
VpcCIDR	10.0.0.0/16	VPC CIDR block
PublicSubnet1CIDR	10.0.1.0/24	Subnet for EC2 #1 & #3
PublicSubnet2CIDR	10.0.2.0/24	Subnet for EC2 #2
InstanceType	t3.micro	EC2 instance type
UbuntuAmiId	ami-0fc5d935ebf8bc3bc	Ubuntu AMI


3. Launch Stack:
Launching the CloudFormation Stack (Full Step-by-Step Guide):

01
Open CloudFormation Console:

You begin by accessing the CloudFormation service where stacks are created and managed.

AWS Console → Services → CloudFormation

Make sure you are in the correct AWS Region

Click Stacks in the left navigation panel

02
Start Creating a New Stack:

Start Here
This step initializes the stack creation workflow.

Click Create stack

Select With new resources (standard)

03
Upload Your Template File:

You provide your JSON template so CloudFormation can read and deploy resources.

Under Prepare template, choose Template source: Upload a template file

Click Choose file and select ALB-for-3-Ubuntu-WebServer-TemplateCloudFormation.json

Click Next

04
Specify Stack Details:

You name the stack and configure template parameters.

Enter a stack name (e.g., ALB-Ubuntu-3WebServer-Stack)

Fill in parameters or keep defaults:

VpcCIDR

PublicSubnet1CIDR

PublicSubnet2CIDR

InstanceType

UbuntuAmiId

Click Next

05
Configure Stack Options:

Optional settings such as tags, permissions, and rollback behavior.

(Optional) Add tags like Project: ALB-Lab

Leave IAM, rollback, and advanced options as default unless required

Click Next

06
Review and Submit:

Deployment Begins
Final verification before CloudFormation begins provisioning resources.

Review all settings

Scroll down and click Submit

CloudFormation begins creating your VPC, subnets, ALB, EC2 instances, and security groups

07
### Monitor Stack Creation:

You track progress and ensure all resources are created successfully.

Watch the Events tab for real-time updates

Wait until the stack status becomes CREATE_COMPLETE

If any resource fails, CloudFormation will show detailed error messages

08
Retrieve the ALB DNS Name:

Success
This is the final step — testing your load balancer.

Go to the Outputs tab

Copy the value of ALBDNS

Paste it into your browser and refresh several times to see Server 1, 2, and 3 responses
4. Test the ALB

After deployment:

Go to EC2 → Load Balancers

Copy the DNS name

Paste it into your browser

Refresh multiple times — you should see:

Server 1 – Load Balancer Test

Server 2 – Load Balancer Test

Server 3 – Load Balancer Test
### Security Notes
ALB is publicly accessible on port 80.

EC2 instances only accept traffic from ALB SG.

No SSH access is enabled (secure by default).

Apache2 serves static HTML only.
## Conclusion
This CloudFormation project successfully demonstrates how to deploy a complete, functional load‑balanced web architecture on AWS using fully automated infrastructure‑as‑code. By provisioning a VPC, public subnets, routing, security groups, three Ubuntu EC2 instances, and an Application Load Balancer, the template delivers a working environment where traffic is evenly distributed across multiple web servers.
The ALB DNS output confirms that the stack is operational, and refreshing the page shows each server’s unique response — validating round‑robin load balancing.
This project is a solid foundation for more advanced architectures such as Auto Scaling Groups, private subnets, HTTPS termination, and multi‑tier designs.

## Lessons Learned
1. CloudFormation Resource Dependencies Matter
You learned how DependsOn ensures correct provisioning order — especially for the Target Group that requires EC2 instances to exist before attachment.

2. Security Group Design Controls Traffic Flow
Separating ALB and EC2 security groups reinforces best practice:

ALB SG → open to the world

EC2 SG → only accepts traffic from ALB SG
This is a clean, secure pattern for public web architectures.

3. UserData Is a Powerful Automation Tool
Using UserData to install Apache2 and generate custom HTML pages shows how EC2 instances can self‑configure at launch without manual intervention.

4. Subnet Placement Affects High Availability
Placing EC2 instances across two Availability Zones improves resilience.
Even though you used only two subnets, the ALB still achieves multi‑AZ load balancing.

5. Outputs Make Testing Easier
The ALBDNS output is a simple but important detail — it makes validation fast and avoids searching through the console.

6. Infrastructure‑as‑Code Builds Repeatable Environments
By defining everything in JSON, you can redeploy this architecture anytime, anywhere, with consistent results.
This is the core value of CloudFormation.

7. Small Design Choices Teach Big Concepts
Even a simple three‑server ALB stack teaches:

VPC fundamentals

Routing

Load balancing

EC2 automation

Security boundaries

Template structure and best practices

You built a complete, real‑world architecture — and you did it cleanly.

If you want, I can also write:

A “What’s Next?” section

A “Troubleshooting” section

A professional GitHub description for your repository

A diagram image for your README

Just tell me what direction you want next.
## Troubleshooting
This section helps you diagnose and fix the most common issues that may occur when launching or testing your ALB‑for‑3‑Ubuntu‑WebServer CloudFormation stack.

1. ALB DNS Loads Nothing (Blank Page / Timeout)
Possible Causes
EC2 instances are not healthy in the Target Group

Apache2 failed to install or start

Security groups are misconfigured

Instances are still initializing

### How to Fix?

Go to EC2 → Target Groups → Targets

Ensure all 3 instances show healthy

SSH into an instance (if you temporarily allow SSH) and run:
sudo systemctl status apache2

Check UserData logs:
/var/log/cloud-init-output.log

Wait 2–3 minutes after stack creation — Apache installation takes time.

2. Target Group Shows “Unhealthy” Instances
Possible Causes
Apache2 not running

Wrong health check path

Security group blocking traffic

UserData failed

### How to Fix?

Verify Apache is running:
sudo systemctl start apache2

Confirm health check path is / (your template uses /)

Ensure InstanceSG allows inbound port 80 from ALBSG only

Check UserData execution logs for errors.

3. Only One Server Responds (No Round‑Robin)
Possible Causes
One or more instances are unhealthy

Sticky sessions enabled (not in your template, but possible if modified)

ALB caching in browser

### How to Fix?

Refresh using Ctrl + Shift + R (forces full reload)

Check Target Group health

Ensure all 3 instances have Apache running

Disable sticky sessions if manually enabled.

4. CloudFormation Stack Fails to Create
Possible Causes
Invalid AMI ID

Subnet CIDR conflicts

Missing permissions (IAM)

Resource naming conflicts (e.g., TargetGroup name already exists)

### How to Fix?

Verify AMI ID is valid in your region

Ensure CIDRs do not overlap

Delete old stacks with similar resource names

Check CloudFormation → Events for exact error messages.

5. EC2 Instances Launch but Apache Page Shows Default Ubuntu Page
Possible Causes
UserData did not overwrite /var/www/html/index.html

Apache started before file was written

UserData syntax error

## How to Fix?

Check UserData logs:
/var/log/cloud-init-output.log

Manually verify file content:
cat /var/www/html/index.html

Reboot instance:
sudo reboot

If needed, redeploy stack.

6. ALB Shows “503 Service Unavailable”
Possible Causes
No healthy targets

Listener not properly attached

Target Group missing instances

### How to Fix?

Confirm listener default action points to your Target Group

Check Target Group → Targets

Ensure instances are registered and healthy.

7. Stack Deletes Itself Automatically (ROLLBACK)
Possible Causes
A required resource failed creation

Dependency chain broken

Incorrect parameter values

### How to Fix?

Check CloudFormation → Events

Identify the failing resource

Fix the issue and redeploy

Consider enabling Rollback Off for debugging.


