#!/bin/bash

# Rollback Script
# This script rolls back the deployment to the previous version

set -e

# Default values
NAMESPACE="itemsapi-test"
CLUSTER_NAME="itemsapi-test-cluster"
AWS_REGION="us-east-1"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENV="$2"
            if [ "$ENV" == "prod" ]; then
                NAMESPACE="itemsapi-prod"
                CLUSTER_NAME="itemsapi-prod-cluster"
            fi
            shift 2
            ;;
        --revision)
            REVISION="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${RED}⚠️  Rolling back deployment in $NAMESPACE${NC}"

# Update kubeconfig
echo -e "${YELLOW}📝 Updating kubeconfig...${NC}"
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Show current rollout history
echo -e "\n${YELLOW}📊 Rollout History:${NC}"
kubectl rollout history deployment/itemsapi-app -n $NAMESPACE

# Perform rollback
if [ -z "$REVISION" ]; then
    echo -e "\n${YELLOW}🔄 Rolling back to previous revision...${NC}"
    kubectl rollout undo deployment/itemsapi-app -n $NAMESPACE
else
    echo -e "\n${YELLOW}🔄 Rolling back to revision $REVISION...${NC}"
    kubectl rollout undo deployment/itemsapi-app --to-revision=$REVISION -n $NAMESPACE
fi

# Wait for rollback to complete
echo -e "${YELLOW}⏳ Waiting for rollback to complete...${NC}"
kubectl rollout status deployment/itemsapi-app -n $NAMESPACE --timeout=300s

# Verify health
echo -e "\n${YELLOW}🏥 Verifying health...${NC}"
sleep 10

ENDPOINT=$(kubectl get svc itemsapi-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ ! -z "$ENDPOINT" ]; then
    if curl -f -s "http://${ENDPOINT}/health" > /dev/null; then
        echo -e "${GREEN}✅ Rollback successful! Application is healthy.${NC}"
    else
        echo -e "${RED}❌ Rollback completed but health check failed.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Could not get service endpoint${NC}"
fi

echo -e "\n${GREEN}Current deployment revision:${NC}"
kubectl get deployment itemsapi-app -n $NAMESPACE -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}{"\n"}'
