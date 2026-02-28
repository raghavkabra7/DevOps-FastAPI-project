#!/bin/bash

# Monitoring Script
# This script shows monitoring information for the deployment

# Default values
NAMESPACE="itemsapi-test"
CLUSTER_NAME="itemsapi-test-cluster"
AWS_REGION="us-east-1"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENV="$2"
            if [ "$ENV" == "prod" ] || [ "$ENV" == "production" ]; then
                NAMESPACE="itemsapi-prod"
                CLUSTER_NAME="itemsapi-prod-cluster"
            fi
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: ./monitor.sh --env [test|prod]"
            exit 1
            ;;
    esac
done

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --output text > /dev/null 2>&1

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        ItemsAPI Monitoring Dashboard - $NAMESPACE       ${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Pods Status
echo -e "${YELLOW}📦 Pods Status:${NC}"
kubectl get pods -n $NAMESPACE -o wide

echo -e "\n${YELLOW}🌐 Services:${NC}"
kubectl get svc -n $NAMESPACE

echo -e "\n${YELLOW}📊 HPA Status:${NC}"
kubectl get hpa -n $NAMESPACE

echo -e "\n${YELLOW}💾 Persistent Volume Claims:${NC}"
kubectl get pvc -n $NAMESPACE

echo -e "\n${YELLOW}⚙️  Deployments:${NC}"
kubectl get deployments -n $NAMESPACE

echo -e "\n${YELLOW}🔄 Recent Events:${NC}"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -10

# Resource Usage
echo -e "\n${YELLOW}📈 Resource Usage:${NC}"
if kubectl top nodes &> /dev/null; then
    echo -e "\n${BLUE}Nodes:${NC}"
    kubectl top nodes
    
    echo -e "\n${BLUE}Pods:${NC}"
    kubectl top pods -n $NAMESPACE
else
    echo -e "${RED}Metrics server not available${NC}"
fi

# Service Endpoint
ENDPOINT=$(kubectl get svc itemsapi-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ ! -z "$ENDPOINT" ]; then
    echo -e "\n${YELLOW}🌐 Service Endpoint:${NC}"
    echo "http://${ENDPOINT}"
    
    echo -e "\n${YELLOW}🏥 Health Check:${NC}"
    if curl -f -s "http://${ENDPOINT}/health" > /dev/null; then
        echo -e "${GREEN}✅ API is healthy${NC}"
        curl -s "http://${ENDPOINT}/health" | python3 -m json.tool
    else
        echo -e "${RED}❌ Health check failed${NC}"
    fi
fi

echo -e "\n${BLUE}────────────────────────────────────────────────────────${NC}"
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs:           kubectl logs -f deployment/itemsapi-app -n $NAMESPACE"
echo "  Describe pod:        kubectl describe pod <pod-name> -n $NAMESPACE"
echo "  Shell into pod:      kubectl exec -it <pod-name> -n $NAMESPACE -- /bin/bash"
echo "  Scale deployment:    kubectl scale deployment/itemsapi-app --replicas=5 -n $NAMESPACE"
echo "  Rollout history:     kubectl rollout history deployment/itemsapi-app -n $NAMESPACE"
echo ""
