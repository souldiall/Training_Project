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
