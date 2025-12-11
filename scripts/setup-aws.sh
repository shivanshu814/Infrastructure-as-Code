#!/bin/bash
# =====================================================
# AWS Setup Script
# =====================================================
# Run this ONCE to setup AWS prerequisites for Terraform

set -e

echo "🚀 Setting up AWS resources for DevOps Learning Project..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="${AWS_REGION:-ap-south-1}"
PROJECT_NAME="${PROJECT_NAME:-devops-learning}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "${YELLOW}Account ID: ${ACCOUNT_ID}${NC}"
echo -e "${YELLOW}Region: ${AWS_REGION}${NC}"
echo ""

# =====================================================
# 1. Create S3 Bucket for Terraform State
# =====================================================
STATE_BUCKET="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}"

echo -e "${GREEN}Creating S3 bucket for Terraform state: ${STATE_BUCKET}${NC}"

if aws s3api head-bucket --bucket "${STATE_BUCKET}" 2>/dev/null; then
    echo "  ↳ Bucket already exists"
else
    aws s3api create-bucket \
        --bucket "${STATE_BUCKET}" \
        --region "${AWS_REGION}" \
        --create-bucket-configuration LocationConstraint="${AWS_REGION}"
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "${STATE_BUCKET}" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket "${STATE_BUCKET}" \
        --server-side-encryption-configuration '{
            "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
        }'
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "${STATE_BUCKET}" \
        --public-access-block-configuration '{
            "BlockPublicAcls": true,
            "IgnorePublicAcls": true,
            "BlockPublicPolicy": true,
            "RestrictPublicBuckets": true
        }'
    
    echo "  ↳ Created and configured"
fi

# =====================================================
# 2. Create DynamoDB Table for State Locking
# =====================================================
LOCK_TABLE="${PROJECT_NAME}-terraform-lock"

echo -e "${GREEN}Creating DynamoDB table for state locking: ${LOCK_TABLE}${NC}"

if aws dynamodb describe-table --table-name "${LOCK_TABLE}" 2>/dev/null; then
    echo "  ↳ Table already exists"
else
    aws dynamodb create-table \
        --table-name "${LOCK_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${AWS_REGION}"
    
    echo "  ↳ Created"
fi

# =====================================================
# 3. Create IAM Role for GitHub Actions (OIDC)
# =====================================================
echo -e "${GREEN}Setting up OIDC for GitHub Actions...${NC}"

# Check if OIDC provider exists
OIDC_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "${OIDC_ARN}" 2>/dev/null; then
    echo "  ↳ OIDC provider already exists"
else
    # Get GitHub's OIDC thumbprint
    THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"
    
    aws iam create-open-id-connect-provider \
        --url "https://token.actions.githubusercontent.com" \
        --client-id-list "sts.amazonaws.com" \
        --thumbprint-list "${THUMBPRINT}"
    
    echo "  ↳ Created OIDC provider"
fi

# =====================================================
# Output
# =====================================================
echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Update terraform/main.tf backend configuration:"
echo "   backend \"s3\" {"
echo "     bucket         = \"${STATE_BUCKET}\""
echo "     key            = \"terraform.tfstate\""
echo "     region         = \"${AWS_REGION}\""
echo "     dynamodb_table = \"${LOCK_TABLE}\""
echo "     encrypt        = true"
echo "   }"
echo ""
echo "2. Create GitHub Actions IAM role with trust policy for your repo"
echo "3. Add AWS_ROLE_ARN secret to GitHub repository"
