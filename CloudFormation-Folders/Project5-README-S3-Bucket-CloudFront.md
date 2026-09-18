# Private S3 Bucket with CloudFront Distribution — AWS CloudFormation

## Overview

This project provisions a **private Amazon S3 bucket** served securely through **Amazon CloudFront** using **AWS CloudFormation** as Infrastructure as Code (IaC). Public access to the S3 bucket is fully blocked; content is only accessible through CloudFront using an **Origin Access Control (OAC)**, following AWS security best practices for static website/content hosting.

- **Provider:** AWS
- **IaC Tool:** AWS CloudFormation
- **Author:** Souleymane Diallo
- **Student ID:** UCT4

---

## Architecture Summary

The CloudFormation template (`template.json`) provisions the following resources:

- **`WebsiteBucket` (AWS::S3::Bucket)** — a private S3 bucket named `my-private-website-bucket-souleymane-2026` with:
  - **Versioning enabled**, to preserve and recover previous object versions.
  - **Full Public Access Block** (`BlockPublicAcls`, `IgnorePublicAcls`, `BlockPublicPolicy`, `RestrictPublicBuckets` all set to `true`), ensuring the bucket cannot be made public by mistake.
- **`CloudFrontOAC` (AWS::CloudFront::OriginAccessControl)** — an Origin Access Control configured for S3 origins, using `sigv4` signing so that only CloudFront can retrieve objects from the bucket.
- **`CloudFrontDistribution` (AWS::CloudFront::Distribution)** — a CloudFront distribution that:
  - Uses the S3 bucket's **RegionalDomainName** as its origin.
  - Attaches the OAC to authenticate requests to the private bucket.
  - Serves `index.html` as the **default root object**.
  - Redirects all viewer traffic to **HTTPS** (`redirect-to-https`).
  - Allows and caches only `GET` and `HEAD` methods.
- **`BucketPolicy` (AWS::S3::BucketPolicy)** — a bucket policy that grants the `cloudfront.amazonaws.com` service principal `s3:GetObject` permission, restricted via a `Condition` so that **only the specific CloudFront distribution** (matched by `AWS:SourceArn`) can read objects — not CloudFront in general.

### Outputs

- **`CloudFrontURL`** — the public HTTPS URL of the CloudFront distribution (e.g., `https://dxxxxxxxxxxxxx.cloudfront.net`), which is how end users access the content.

### Why this design?

Serving S3 content through CloudFront with OAC (rather than making the bucket public) means:
- The **S3 bucket stays fully private** — no public ACLs, no public bucket policy for end users.
- CloudFront provides **HTTPS, caching, and global edge delivery**.
- Access is locked down to **one specific distribution** via the `AWS:SourceArn` condition, preventing other AWS accounts' CloudFront distributions from reading the bucket even if they somehow reference it.

---

## Prerequisites

Before deploying this stack, ensure you have:

1. An active **AWS account** with permissions to create S3, CloudFront, and IAM/bucket policy resources.
2. Access to the **AWS Management Console**.
3. A **globally unique S3 bucket name** — if `my-private-website-bucket-souleymane-2026` is already taken (S3 bucket names are unique across all of AWS, not just your account), update `BucketName` in the template before deploying.
4. (Optional) Website content (e.g., `index.html` and supporting files) ready to upload to the bucket after the stack is created — the template only creates the bucket and distribution; it does not upload files.

---

## Deployment Instructions (AWS Management Console)

### 1. Open CloudFormation

Sign in to the **AWS Management Console**, then navigate to **Services → CloudFormation**.

### 2. Create a new stack

- Click **Create stack** → **With new resources (standard)**.
- Under **Prerequisite - Prepare template**, select **Template is ready**.
- Under **Specify template**, select **Upload a template file**, then click **Choose file** and select the `template.json` file.
- Click **Next**.

### 3. Specify stack details

- Enter a **Stack name** (e.g., `s3-cloudfront-stack`).
- This template has no parameters to fill in — the bucket name and configuration are hardcoded in the template.
- Click **Next**.

### 4. Configure stack options

- (Optional) Add **Tags** (e.g., `Owner: Souleymane Diallo`, `Project: UCT4`) to help identify the stack's resources.
- Leave the remaining defaults unless your setup requires otherwise.
- Click **Next**.

### 5. Review and create

- Review all resources that will be created: `WebsiteBucket`, `CloudFrontOAC`, `CloudFrontDistribution`, and `BucketPolicy`.
- This template does **not** create IAM roles/users, so no IAM acknowledgment checkbox should be required — but check the box if the console prompts for it.
- Click **Submit** (or **Create stack**).

### 6. Monitor stack creation

- On the stack's **Events** tab, watch the resources being created in real time.
- **Note:** CloudFront distributions typically take **10–20 minutes** to fully deploy, even after CloudFormation reports `CREATE_COMPLETE` for the resource — the distribution status in the CloudFront console will show "Deploying" until it's ready.
- Once complete, go to the **Outputs** tab of the stack to copy the `CloudFrontURL`.

### 7. Upload content to the bucket

- Go to **S3 Console → Buckets → `my-private-website-bucket-souleymane-2026`**.
- Click **Upload** and add your website files (e.g., `index.html`).
- No need to set any object or bucket ACLs — access is handled entirely through CloudFront + OAC.

### 8. Update the stack (after making changes)

- Select the stack from the **Stacks** list.
- Click **Update**.
- Choose **Replace current template**, upload the revised `template.json`, and click through **Next** on each step.
- Review the **Change set** preview, then click **Update stack**.

### 9. Delete the stack (cleanup)

- Empty the S3 bucket first (S3 buckets with objects cannot be deleted by CloudFormation automatically): go to **S3 Console → select the bucket → Empty**.
- Select the stack from the **Stacks** list in CloudFormation.
- Click **Delete**, then confirm the deletion.
- Monitor the **Events** tab until the stack status changes to **DELETE_COMPLETE**.

---

## Verifying the Deployment

- Open the **`CloudFrontURL`** shown in the stack's **Outputs** tab in a browser — you should see your `index.html` content served over HTTPS.
- Try accessing the S3 bucket's direct URL or the object's S3 URL directly — this should be **denied** (proving the bucket is private and only reachable via CloudFront).
- In **S3 Console → Bucket → Permissions**, confirm **Block all public access** is enabled.
- In **CloudFront Console → Distributions**, confirm the distribution status is **Enabled** and **Deployed**, and that the origin is correctly configured with the OAC attached.

---

## Conclusion

This project demonstrates how to securely serve content from a private S3 bucket using CloudFront and Origin Access Control, fully defined and deployed through AWS CloudFormation. By blocking all public access on the bucket and restricting object access to a single, named CloudFront distribution via a scoped bucket policy condition, the architecture achieves both strong security posture and reliable, HTTPS-enabled global content delivery. Using CloudFormation to define this stack ensures the setup is repeatable, auditable, and easy to redeploy or tear down as needed.

---

## Lessons Learned

- **OAC is the modern replacement for OAI.** Origin Access Control (`AWS::CloudFront::OriginAccessControl`) is AWS's current recommended method for giving CloudFront exclusive access to a private S3 bucket, replacing the older Origin Access Identity (OAI) approach, and supports SigV4 signing for stronger security.
- **Public Access Block settings are essential.** Explicitly setting all four `PublicAccessBlockConfiguration` flags to `true` ensures the bucket cannot become public even if a misconfigured policy or ACL is later applied.
- **Bucket policies must be scoped tightly.** Using a `Condition` with `AWS:SourceArn` tied to the specific CloudFront distribution ARN prevents any other CloudFront distribution (including ones in other AWS accounts) from being able to read the bucket's objects.
- **CloudFront deployment takes time.** Even after CloudFormation marks the distribution resource as `CREATE_COMPLETE`, the distribution can take 10–20 minutes to fully propagate to all edge locations before content is reliably available worldwide.
- **S3 bucket names are globally unique.** Hardcoding a bucket name in the template (as this one does) risks a naming collision — it's often safer to use CloudFormation intrinsic functions (e.g., `!Sub` with `${AWS::AccountId}` or `${AWS::StackName}`) to auto-generate a unique name.
- **CloudFormation can't delete non-empty S3 buckets.** Attempting to delete a stack while the bucket still has objects (and versions, since versioning is enabled) will fail — the bucket, and all object versions, must be emptied manually first.
- **`ForwardedValues` is a legacy setting.** The template uses the older `ForwardedValues` block for the cache behavior; AWS now recommends using **Cache Policies** and **Origin Request Policies** for more granular control, though `ForwardedValues` still works for simple cases.

---

## Troubleshooting

| Issue | Likely Cause | Resolution |
|---|---|---|
| Stack creation fails with `WebsiteBucket already exists` | The hardcoded `BucketName` is already taken globally (S3 names are unique across all AWS accounts) | Edit `BucketName` in the template to a unique value, then retry stack creation |
| `Access Denied` when opening the CloudFront URL | Distribution not fully deployed yet, or OAC/bucket policy misconfigured | Wait for the distribution status to show **Deployed** in the CloudFront console; verify `BucketPolicy` references the correct distribution ARN |
| `403 Forbidden` when accessing the S3 object directly | Expected behavior — the bucket is private and only readable via CloudFront | This is by design; always access content through the `CloudFrontURL`, not the S3 URL |
| Blank page or `404` at the CloudFront URL | No `index.html` uploaded to the bucket yet | Upload `index.html` (and other assets) to the S3 bucket via the S3 Console |
| Stack `DELETE_FAILED` on the S3 bucket | The bucket still contains objects or object versions (versioning is enabled) | Go to **S3 Console → bucket → Empty**, ensure all versions/delete markers are removed, then retry stack deletion |
| Changes to `index.html` not appearing after re-upload | CloudFront is serving a **cached** version of the old file | Create a **CloudFront invalidation** (Console → Distribution → Invalidations → Create invalidation → `/*`) to force a refresh |
| `BucketPolicy` fails to create with a circular dependency error | The policy's `Condition` references the `CloudFrontDistribution` before it exists | Ensure the resources are declared correctly (CloudFormation generally handles this automatically via implicit `Ref`/`Fn::GetAtt` dependencies) — if it persists, add an explicit `DependsOn` on `CloudFrontDistribution` in `BucketPolicy` |
| `Template format error` on upload | Invalid JSON syntax (missing comma, unmatched brace, etc.) | On the **Create stack** page, use **Template is ready → Upload a template file**, then click **View in Designer** to visually validate the template before proceeding |

---

## Author

**Souleymane Diallo**
Student ID: **UCT4**
