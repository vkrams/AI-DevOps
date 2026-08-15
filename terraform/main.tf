# main.tf
# Simple Terraform configuration to provision:
#   - a single AWS EC2 instance
#   - an S3 bucket
#   - an IAM role/instance profile so the EC2 instance can access the bucket
# Beginner-friendly: one file, no modules, minimal variables.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# AWS provider — using the Sydney region (ap-southeast-2)
provider "aws" {
  region = "ap-southeast-2"
}

# Common tags applied to every resource, so they're easy to find/manage.
locals {
  common_tags = {
    Name    = "ai-devops-demo"
    Project = "ai-devops-demo"
  }
}

# ---------------------------------------------------------------------------
# EC2 instance
# ---------------------------------------------------------------------------

# Look up the latest Amazon Linux 2023 AMI, always kept up to date by AWS.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# A single EC2 instance using the free-tier eligible t2.micro type.
# It's launched with the IAM instance profile below, which grants it
# permission to read/write objects in the S3 bucket.
resource "aws_instance" "ai_devops_demo" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_access.name

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# S3 bucket
# ---------------------------------------------------------------------------

# S3 bucket names must be globally unique across all of AWS, so a random
# suffix is appended to avoid clashing with buckets other people have made.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "ai_devops_demo" {
  bucket = "ai-devops-demo-${random_id.bucket_suffix.hex}"

  tags = local.common_tags
}

# Keep the bucket private by default — good practice for a demo bucket.
resource "aws_s3_bucket_public_access_block" "ai_devops_demo" {
  bucket = aws_s3_bucket.ai_devops_demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------------------
# IAM: allow the EC2 instance to access the S3 bucket
# ---------------------------------------------------------------------------

# Trust policy: allows EC2 instances to assume this role.
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_s3_access" {
  name               = "ai-devops-demo-ec2-s3-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.common_tags
}

# Permissions policy: lets the role read/write objects in the bucket, and
# list the bucket's contents. Scoped to just this bucket, nothing broader.
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.ai_devops_demo.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.ai_devops_demo.arn]
  }
}

resource "aws_iam_role_policy" "ec2_s3_access" {
  name   = "ai-devops-demo-ec2-s3-policy"
  role   = aws_iam_role.ec2_s3_access.id
  policy = data.aws_iam_policy_document.s3_access.json
}

# Instance profile — this is what actually gets attached to the EC2 instance.
resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "ai-devops-demo-ec2-s3-profile"
  role = aws_iam_role.ec2_s3_access.name
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ai_devops_demo.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ai_devops_demo.public_ip
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.ai_devops_demo.bucket
}
