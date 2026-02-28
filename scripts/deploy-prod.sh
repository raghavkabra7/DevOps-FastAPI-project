#!/bin/bash

# AWS EKS Deployment Script for Production Environment
# This script deploys the application to the production environment on AWS EKS

set -e

echo "🚀 Starting deployment to PRODUCTION environment..."

# Configuration
CLUSTER_NAME="itemsapi-prod-cluster"
AWS_REGION="us-east-1"
NAMESPACE="itemsapi-prod"
DOCKER_IMAGE="raghavkabra7/itemsapi:latest"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Confirmation prompt
echo -e "${RED}⚠️  WARNING: You are about to deploy to PRODUCTION!${NC}"
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install it first.${NC}"
    exit 1
fi

# Update kubeconfig
echo -e "${YELLOW}📝 Updating kubeconfig...${NC}"
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Verify connection to cluster
echo -e "${YELLOW}🔍 Verifying cluster connection...${NC}"
kubectl cluster-info

# Create backup of current deployment
echo -e "${YELLOW}💾 Creating backup...${NC}"
kubectl get deployment itemsapi-app -n $NAMESPACE -o yaml > backup-deployment-$(date +%Y%m%d-%H%M%S).yaml 2>/dev/null || true

# Create namespace if it doesn't exist
echo -e "${YELLOW}📦 Creating namespace...${NC}"
kubectl apply -f kubernetes/prod/namespace.yaml

# Apply ConfigMap and Secrets
echo -e "${YELLOW}⚙️  Applying ConfigMap and Secrets...${NC}"
kubectl apply -f kubernetes/prod/configmap.yaml
kubectl apply -f kubernetes/prod/secret.yaml

# Deploy PostgreSQL
echo -e "${YELLOW}🗄️  Deploying PostgreSQL...${NC}"
kubectl apply -f kubernetes/prod/postgres-deployment.yaml

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=300s

# Deploy application
echo -e "${YELLOW}🚀 Deploying application...${NC}"
kubectl apply -f kubernetes/prod/app-deployment.yaml

# Update image if specified
if [ ! -z "$1" ]; then
    DOCKER_IMAGE=$1
    echo -e "${YELLOW}🔄 Updating image to $DOCKER_IMAGE...${NC}"
    kubectl set image deployment/itemsapi-app fastapi-app=$DOCKER_IMAGE -n $NAMESPACE
fi

# Wait for deployment to complete
echo -e "${YELLOW}⏳ Waiting for deployment to complete (max 10 minutes)...${NC}"
kubectl rollout status deployment/itemsapi-app -n $NAMESPACE --timeout=600s

# Get service endpoint
echo -e "${YELLOW}🌐 Getting service endpoint...${NC}"
kubectl get svc itemsapi-service -n $NAMESPACE

# Run health check
echo -e "${YELLOW}🏥 Running health check...${NC}"
sleep 10

ENDPOINT=$(kubectl get svc itemsapi-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -z "$ENDPOINT" ]; then
    echo -e "${YELLOW}⚠️  LoadBalancer endpoint not ready yet. Waiting...${NC}"
    sleep 30
    ENDPOINT=$(kubectl get svc itemsapi-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
fi

if [ ! -z "$ENDPOINT" ]; then
    echo -e "${YELLOW}Testing health endpoint: http://${ENDPOINT}/health${NC}"
    sleep 5
    if curl -f -s "http://${ENDPOINT}/health" > /dev/null; then
        echo -e "${GREEN}✅ Health check passed!${NC}"
    else
        echo -e "${RED}❌ Health check failed! Consider rolling back.${NC}"
        echo -e "${YELLOW}Run: kubectl rollout undo deployment/itemsapi-app -n $NAMESPACE${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Deployment to PRODUCTION environment completed successfully!${NC}"
echo -e "${GREEN}📊 Check deployment status: kubectl get pods -n $NAMESPACE${NC}"
echo -e "${GREEN}📝 View logs: kubectl logs -f deployment/itemsapi-app -n $NAMESPACE${NC}"
echo -e "${GREEN}🌐 API endpoint: http://${ENDPOINT}${NC}"
echo -e "${GREEN}📈 Monitor HPA: kubectl get hpa -n $NAMESPACE${NC}"
