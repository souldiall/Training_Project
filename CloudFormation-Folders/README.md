# Project: 
Multi-OS-Template-CloudFormation.json  
## Purpose:
Deploy three EC2 instances, each running a different OS: Windows Server, Amazon Linux, and Ubuntu Server — using a single CloudFormation template with OS‑based conditions.

## Overview
This project demonstrates how to deploy multiple operating systems using one CloudFormation template.
The template uses:

A parameter to select OS types

Conditions to determine which UserData and AMI to use

Fn::If logic to dynamically switch between Windows, Amazon Linux, and Ubuntu

Three EC2 resources, each with its own OS value

This pattern is essential for multi‑OS automation and reusable infrastructure.

## Project Structure
Code
Multi-OS-Template-CloudFormation.json
README.md
### How the Template Works
1️⃣ OS Parameter
Each EC2 instance receives an OS value such as:

Windows

AmazonLinux

Ubuntu

This allows CloudFormation to evaluate conditions and apply the correct AMI + UserData.

2️⃣ Conditions
The template defines conditions like:

IsWindows

IsAmazonLinux

IsUbuntu

These conditions are used inside Fn::If blocks to switch logic.

3️⃣ AMI Selection
Each OS uses a different AMI lookup pattern:

OS	AMI Source
Windows	AWS Windows Server AMIs
Amazon Linux	AL2023 AMI via SSM Parameter
Ubuntu	Canonical Ubuntu AMIs


4️⃣ UserData Logic
Each OS has its own bootstrap script:

OS	Web Server Installed	UserData Type
Windows	IIS	PowerShell
Amazon Linux	httpd	Bash
Ubuntu	apache2	Bash


CloudFormation uses nested Fn::If to select the correct script.

### EC2 Instances Created
The template launches three EC2 instances, each with a different OS:

Instance Name	OS	Purpose
WindowsServerInstance	Windows Server	IIS Web Server
AmazonLinuxInstance	Amazon Linux 2023	httpd Web Server
UbuntuServerInstance	Ubuntu Server	apache2 Web Server


Each instance writes custom HTML to its web root.

### Deployment Instructions
1. Upload the Template
Upload Multi-OS-Template-CloudFormation.json to:

directly into the CloudFormation console

2. Create the Stack
In AWS Console:

Go to CloudFormation

Click Create stack

Choose Upload a template file

Select Multi-OS-Template-CloudFormation.json

Click Next

3. Provide Parameters
You will see parameters for:

VPC ID

Subnet ID

KeyPair

Custom HTML content

Each EC2 resource already has its OS hard‑coded (Windows, AmazonLinux, Ubuntu).

4. Deploy
Click Create Stack  
CloudFormation will:

Evaluate OS conditions

Select the correct AMI

Apply the correct UserData

Launch all three EC2 instances

### Testing the Deployment
#### Windows Instance
Open browser →
http://<Windows-Instance-Public-IP>

#### Amazon Linux Instance
Open browser →
http://<AmazonLinux-Instance-Public-IP>

#### Ubuntu Instance
Open browser →
http://<Ubuntu-Instance-Public-IP>

Each should display your custom HTML.

##  Key CloudFormation Features Used
Parameters

Conditions

Fn::Equals

Fn::If

Fn::Sub

Fn::Base64

SSM Parameter Store AMI lookup

EC2 UserData automation

This template is a strong foundation for multi‑OS automation and reusable infrastructure patterns.
