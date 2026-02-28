# ⚡ Quick Commands Reference

## 🐳 Docker Commands

### Start Application Locally
```bash
cd /private/tmp/devops-fastapi-project
docker-compose up -d
```

### Check Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs -f
```

### Stop Application
```bash
docker-compose down
```

### Restart After Code Changes
```bash
docker-compose down
docker-compose up -d --build
```

### Test API Health
```bash
curl http://localhost:8000/health
```

### View API Documentation
Open in browser: http://localhost:8000/docs

---

## 🐙 Git/GitHub Commands

### First Time Setup
```bash
cd /private/tmp/devops-fastapi-project
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR-USERNAME/devops-fastapi-project.git
git branch -M main
git push -u origin main
```

### Create Develop Branch
```bash
git checkout -b develop
git push -u origin develop
```

### Regular Workflow
```bash
# Make changes to code...

# Check what changed
git status

# Add changes
git add .

# Commit with message
git commit -m "Your message here"

# Push to GitHub
git push origin develop  # or 'main'
```

### Switch Between Branches
```bash
git checkout main      # Switch to main
git checkout develop   # Switch to develop
```

---

## ☁️ AWS Commands

### Configure AWS CLI (First Time Only)
```bash
aws configure
# Enter: Access Key ID
# Enter: Secret Access Key
# Enter: Region (us-east-1)
# Enter: Format (json)
```

### Create EKS Test Cluster
```bash
eksctl create cluster \
  --name itemsapi-test-cluster \
  --region us-east-1 \
  --node-type t3.medium \
  --nodes 2
```

### Create EKS Production Cluster
```bash
eksctl create cluster \
  --name itemsapi-prod-cluster \
  --region us-east-1 \
  --node-type t3.large \
  --nodes 3
```

### Connect to Cluster
```bash
# Test cluster
aws eks update-kubeconfig --name itemsapi-test-cluster --region us-east-1

# Production cluster
aws eks update-kubeconfig --name itemsapi-prod-cluster --region us-east-1
```

### Delete Cluster (To Save Money!)
```bash
eksctl delete cluster --name itemsapi-test-cluster --region us-east-1
eksctl delete cluster --name itemsapi-prod-cluster --region us-east-1
```

---

## ☸️ Kubernetes Commands

### View Pods
```bash
kubectl get pods -n itemsapi-test
kubectl get pods -n itemsapi-prod
```

### View Services
```bash
kubectl get svc -n itemsapi-test
kubectl get svc -n itemsapi-prod
```

### View Logs
```bash
# Replace POD-NAME with actual pod name from 'kubectl get pods'
kubectl logs POD-NAME -n itemsapi-test
kubectl logs -f POD-NAME -n itemsapi-test  # Follow logs
```

### Get Service URL
```bash
kubectl get svc itemsapi-service -n itemsapi-test -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### Deploy/Update Application
```bash
# Test environment
kubectl apply -f kubernetes/test/

# Production environment
kubectl apply -f kubernetes/prod/
```

### Scale Application
```bash
kubectl scale deployment/itemsapi-app --replicas=5 -n itemsapi-test
```

### Rollback Deployment
```bash
kubectl rollout undo deployment/itemsapi-app -n itemsapi-test
```

### Delete Everything
```bash
kubectl delete namespace itemsapi-test
kubectl delete namespace itemsapi-prod
```

---

## 🧪 Testing Commands

### Run Tests Locally
```bash
# First time: Create virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements-dev.txt

# Run tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Format Code
```bash
black app/ tests/
```

### Lint Code
```bash
pylint app/
```

---

## 🔍 Troubleshooting Commands

### Check Docker Status
```bash
docker ps                    # Running containers
docker images                # Available images
docker system df             # Disk usage
docker system prune          # Clean up unused resources
```

### Check GitHub Actions
Go to: https://github.com/YOUR-USERNAME/devops-fastapi-project/actions

### Check Docker Hub Images
Go to: https://hub.docker.com/r/YOUR-USERNAME/itemsapi

### Test API Endpoints

#### Health Check
```bash
curl http://localhost:8000/health
```

#### Create Item
```bash
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "Gaming laptop",
    "price": 1500.00,
    "quantity": 5
  }'
```

#### List Items
```bash
curl http://localhost:8000/items
```

#### Get Item by ID
```bash
curl http://localhost:8000/items/1
```

#### Update Item
```bash
curl -X PUT http://localhost:8000/items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "price": 1400.00,
    "quantity": 10
  }'
```

#### Delete Item
```bash
curl -X DELETE http://localhost:8000/items/1
```

---

## 📊 Monitoring Commands

### View Resource Usage
```bash
# Kubernetes
kubectl top nodes
kubectl top pods -n itemsapi-test

# Docker
docker stats
```

### Monitor Deployment
```bash
kubectl rollout status deployment/itemsapi-app -n itemsapi-test
```

### Watch Pods in Real-time
```bash
watch kubectl get pods -n itemsapi-test
```

---

## 🔑 Where to Find Credentials

### Docker Hub Username
1. Log in to https://hub.docker.com
2. Look at top-right corner or URL: hub.docker.com/u/**YOUR-USERNAME**

### Docker Hub Token
1. Docker Hub → Account Settings → Security
2. Click "New Access Token"
3. Copy the generated token

### AWS Access Key ID & Secret
1. AWS Console → Search "IAM"
2. Users → Select your user
3. Security credentials → Create access key
4. Copy both Access Key ID and Secret Access Key

### GitHub Personal Access Token
1. GitHub → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token
4. Select scopes: repo, workflow
5. Copy the token

---

## 🚀 Deployment Workflow

### Deploy to Test Environment
```bash
git checkout develop
# Make your changes...
git add .
git commit -m "New feature"
git push origin develop
# GitHub Actions will automatically deploy to test
```

### Deploy to Production
```bash
git checkout main
git merge develop
git push origin main
# GitHub Actions will automatically deploy to production
```

---

## 💰 Cost Management

### Check AWS Costs
```bash
# View running EKS clusters
eksctl get cluster --region us-east-1

# View EC2 instances
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType]' --output table
```

### Stop EKS to Save Money
```bash
# Delete test cluster
eksctl delete cluster --name itemsapi-test-cluster --region us-east-1

# Delete production cluster
eksctl delete cluster --name itemsapi-prod-cluster --region us-east-1
```

**Note:** This will delete everything! Back up data first!

---

## 📱 URLs to Remember

- **Local API**: http://localhost:8000
- **Local Docs**: http://localhost:8000/docs
- **GitHub Repo**: https://github.com/YOUR-USERNAME/devops-fastapi-project
- **GitHub Actions**: https://github.com/YOUR-USERNAME/devops-fastapi-project/actions
- **Docker Hub**: https://hub.docker.com/r/YOUR-USERNAME/itemsapi
- **AWS Console**: https://console.aws.amazon.com

---

## 🆘 Emergency Commands

### Stop Everything Docker
```bash
docker stop $(docker ps -aq)
docker-compose down
```

### Clean Up Docker
```bash
docker system prune -a --volumes
# WARNING: This deletes all stopped containers, unused images, and volumes!
```

### Reset Git Repository
```bash
git reset --hard HEAD
git clean -fd
# WARNING: This removes all uncommitted changes!
```

### Fix "Port Already in Use"
```bash
# Find what's using port 8000
lsof -ti:8000

# Kill the process (replace PID with the number from above)
kill -9 PID

# Or just restart Docker Desktop
```

---

**Keep this file handy for quick reference!** 📌
