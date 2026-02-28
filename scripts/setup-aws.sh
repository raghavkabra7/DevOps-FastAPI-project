#!/bin/bash

# AWS EKS Setup Script
# This script sets up the required AWS infrastructure for the application

set -e

echo "☁️  AWS EKS Infrastructure Setup"
echo "================================"

# Configuration
AWS_REGION="us-east-1"
TEST_CLUSTER="itemsapi-test-cluster"
PROD_CLUSTER="itemsapi-prod-cluster"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if required tools are installed
echo -e "${YELLOW}🔍 Checking required tools...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    echo "Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

if ! command -v eksctl &> /dev/null; then
    echo -e "${RED}❌ eksctl is not installed${NC}"
    echo "Install: https://eksctl.io/installation/"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    echo "Install: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

echo -e "${GREEN}✅ All required tools are installed${NC}"

# Configure AWS credentials if not already configured
echo -e "\n${YELLOW}🔐 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo "Run: aws configure"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account: $ACCOUNT_ID${NC}"

# Create EKS Clusters
echo -e "\n${YELLOW}🏗️  Creating EKS Clusters...${NC}"
echo "This will take approximately 15-20 minutes per cluster"

# Create Test Cluster
echo -e "\n${YELLOW}📦 Creating TEST cluster: $TEST_CLUSTER${NC}"
read -p "Create test cluster? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    eksctl create cluster \
        --name $TEST_CLUSTER \
        --region $AWS_REGION \
        --node-type t3.medium \
        --nodes 2 \
        --nodes-min 1 \
        --nodes-max 3 \
        --managed \
        --with-oidc \
        --alb-ingress-access
    
    echo -e "${GREEN}✅ Test cluster created${NC}"
fi

# Create Production Cluster
echo -e "\n${YELLOW}🏭 Creating PRODUCTION cluster: $PROD_CLUSTER${NC}"
read -p "Create production cluster? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    eksctl create cluster \
        --name $PROD_CLUSTER \
        --region $AWS_REGION \
        --node-type t3.large \
        --nodes 3 \
        --nodes-min 2 \
        --nodes-max 5 \
        --managed \
        --with-oidc \
        --alb-ingress-access
    
    echo -e "${GREEN}✅ Production cluster created${NC}"
fi

# Install Metrics Server
echo -e "\n${YELLOW}📊 Installing Metrics Server (for HPA)...${NC}"
for CLUSTER in $TEST_CLUSTER $PROD_CLUSTER; do
    if eksctl get cluster --name $CLUSTER --region $AWS_REGION &> /dev/null; then
        echo -e "${YELLOW}Installing metrics-server on $CLUSTER...${NC}"
        aws eks update-kubeconfig --name $CLUSTER --region $AWS_REGION
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
        echo -e "${GREEN}✅ Metrics server installed on $CLUSTER${NC}"
    fi
done

# Optional: Create ECR Repository
echo -e "\n${YELLOW}🐳 Docker Registry Setup${NC}"
read -p "Create AWS ECR repository? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    aws ecr create-repository \
        --repository-name itemsapi \
        --region $AWS_REGION \
        --image-scanning-configuration scanOnPush=true || echo "Repository may already exist"
    
    ECR_URI=$(aws ecr describe-repositories --repository-names itemsapi --region $AWS_REGION --query 'repositories[0].repositoryUri' --output text)
    echo -e "${GREEN}✅ ECR Repository created: $ECR_URI${NC}"
    echo -e "${YELLOW}📝 Update your CI/CD pipeline and Kubernetes manifests with this URI${NC}"
fi

# Optional: Create RDS PostgreSQL
echo -e "\n${YELLOW}🗄️  Database Setup${NC}"
read -p "Create RDS PostgreSQL instances? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}Note: This will create billable resources. Make sure to have appropriate VPC and subnets.${NC}"
    echo -e "${YELLOW}You may want to create RDS instances manually through AWS Console for better control.${NC}"
    echo -e "${YELLOW}Alternatively, use PostgreSQL pods in Kubernetes (already configured).${NC}"
fi

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ AWS Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Configure GitHub Secrets:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - DOCKER_USERNAME"
echo "   - DOCKER_PASSWORD"
echo ""
echo "2. Update configurations:"
echo "   - Update cluster names in .github/workflows/ci-cd.yml"
echo "   - Update Docker image names in Kubernetes manifests"
echo "   - Update AWS region if different"
echo ""
echo "3. Deploy application:"
echo "   - Push to 'develop' branch to deploy to test"
echo "   - Push to 'main' branch to deploy to production"
echo ""
echo -e "${YELLOW}📝 Cluster Access:${NC}"
echo "   Test:  aws eks update-kubeconfig --name $TEST_CLUSTER --region $AWS_REGION"
echo "   Prod:  aws eks update-kubeconfig --name $PROD_CLUSTER --region $AWS_REGION"
echo ""
echo -e "${YELLOW}💰 Cost Estimate (approximate):${NC}"
echo "   - EKS Control Plane: \$0.10/hour per cluster"
echo "   - EC2 Nodes: \$0.0416/hour per t3.medium, \$0.0832/hour per t3.large"
echo "   - Data transfer and other services as used"
echo ""
echo -e "${RED}⚠️  Remember to delete resources when done to avoid charges!${NC}"
echo "   Delete: eksctl delete cluster --name <cluster-name> --region $AWS_REGION"
