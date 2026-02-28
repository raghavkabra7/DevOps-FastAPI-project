# 🚀 Complete DevOps FastAPI Setup Guide

**Step-by-Step Guide to Set Up This Project on Any Fresh Laptop**

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [GitHub Repository Setup](#github-repository-setup)
4. [Docker Hub Setup](#docker-hub-setup)
5. [CI/CD Pipeline Setup](#cicd-pipeline-setup)
6. [AWS & Kubernetes Setup](#aws--kubernetes-setup)
7. [Deploy Application](#deploy-application)
8. [Access Your Application](#access-your-application)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software Installation

1. **Docker Desktop**
   ```bash
   # Download from: https://www.docker.com/products/docker-desktop
   # After installation, verify:
   docker --version
   docker-compose --version
   ```

2. **Git**
   ```bash
   # macOS (using Homebrew):
   brew install git
   
   # Verify:
   git --version
   ```

3. **Python 3.11+**
   ```bash
   # macOS (using Homebrew):
   brew install python@3.11
   
   # Verify:
   python3 --version
   ```

4. **AWS CLI**
   ```bash
   # macOS:
   brew install awscli
   
   # Verify:
   aws --version
   ```

5. **eksctl** (for Kubernetes on AWS)
   ```bash
   # macOS:
   brew install eksctl
   
   # Verify:
   eksctl version
   ```

6. **kubectl** (Kubernetes CLI)
   ```bash
   # macOS:
   brew install kubectl
   
   # Verify:
   kubectl version --client
   ```

---

## Local Development Setup

### Step 1: Clone the Repository

```bash
# Clone from GitHub
git clone https://github.com/raghavkabra7/DevOps-FastAPI-project.git
cd DevOps-FastAPI-project
```

### Step 2: Start Docker Desktop

```bash
# macOS: Start Docker Desktop application
open -a Docker

# Wait for Docker to start (about 30 seconds)
# Verify Docker is running:
docker ps
```

### Step 3: Run Application Locally

```bash
# Start all services (PostgreSQL + FastAPI)
docker-compose up -d

# Wait 30 seconds for services to start

# Verify containers are running:
docker-compose ps

# Test the application:
curl http://localhost:8000/health
```

### Step 4: Access Local Application

Open in browser:
- **API Documentation**: http://localhost:8000/docs
- **Alternative Docs**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

### Step 5: Stop Local Application

```bash
# Stop services:
docker-compose down
```

---

## GitHub Repository Setup

### Step 1: Create GitHub Account

1. Go to https://github.com
2. Click "Sign up"
3. Complete registration
4. Verify your email

### Step 2: Create Personal Access Token (PAT)

1. Log in to GitHub
2. Click your profile picture → **Settings**
3. Scroll down → **Developer settings** (bottom left)
4. Click **Personal access tokens** → **Tokens (classic)**
5. Click **Generate new token** → **Generate new token (classic)**
6. Name: `DevOps-Project-Token`
7. Select scopes:
   - ✅ `repo` (all)
   - ✅ `workflow`
   - ✅ `write:packages`
8. Click **Generate token**
9. **COPY THE TOKEN IMMEDIATELY** - you won't see it again!
   - Save it somewhere safe (e.g., `ghp_xxxxxxxxxxxx`)

### Step 3: Create GitHub Repository

1. Click "+" icon (top right) → **New repository**
2. Repository name: `DevOps-FastAPI-project`
3. Description: "Complete DevOps FastAPI project with CI/CD"
4. Visibility: **Public** or **Private**
5. **DO NOT** check "Add README" (we already have one)
6. Click **Create repository**

### Step 4: Push Code to GitHub

```bash
# Navigate to project directory
cd /path/to/devops-fastapi-project

# Initialize git (if not already done)
git init

# Configure git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Complete DevOps FastAPI project"

# Add GitHub repository as remote
# Replace YOUR_USERNAME and YOUR_TOKEN
git remote add origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/YOUR_USERNAME/DevOps-FastAPI-project.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Example** (replace with your details):
```bash
git remote add origin https://YOUR_GITHUB_USERNAME:YOUR_GITHUB_TOKEN@github.com/YOUR_GITHUB_USERNAME/DevOps-FastAPI-project.git
git push -u origin main

# Real example format:
# git remote add origin https://raghavkabra7:ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx@github.com/raghavkabra7/DevOps-FastAPI-project.git
```

---

## Docker Hub Setup

### Step 1: Create Docker Hub Account

1. Go to https://hub.docker.com
2. Click **Sign Up**
3. Complete registration
4. Verify your email

### Step 2: Create Access Token

1. Log in to Docker Hub
2. Click your username (top right) → **Account Settings**
3. Click **Security** tab
4. Click **New Access Token**
5. Description: `GitHub-Actions-CI-CD`
6. Access permissions: **Read, Write, Delete**
7. Click **Generate**
8. **COPY THE TOKEN IMMEDIATELY** - format: `dckr_pat_xxxxxxxxxx`

### Step 3: Login to Docker Hub Locally (Optional)

```bash
# Login to Docker Hub
docker login -u YOUR_DOCKERHUB_USERNAME

# Enter the access token when prompted for password
# Not your Docker Hub password!
```

**Example**:
```bash
docker login -u raghavkabra7
# Password: dckr_pat_xxxxxxxxxxxxxxxxxxxxxx (paste your token here)
```

---

## CI/CD Pipeline Setup

### Step 1: Configure GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** tab
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret** for each:

**Add these secrets:**

**Secret 1: DOCKER_USERNAME**
- Name: `DOCKER_USERNAME`
- Value: Your Docker Hub username (e.g., `raghavkabra7`)

**Secret 2: DOCKER_PASSWORD**
- Name: `DOCKER_PASSWORD`
- Value: Your Docker Hub access token (e.g., `dckr_pat_xxxxxxxxxxxxxxxxxxxxxx`)

**Secret 3: AWS_ACCESS_KEY_ID** (Optional - for AWS deployment)
- Name: `AWS_ACCESS_KEY_ID`
- Value: Your AWS access key ID

**Secret 4: AWS_SECRET_ACCESS_KEY** (Optional - for AWS deployment)
- Name: `AWS_SECRET_ACCESS_KEY`
- Value: Your AWS secret access key

**Secret 5: AWS_SESSION_TOKEN** (Optional - if using temporary credentials)
- Name: `AWS_SESSION_TOKEN`
- Value: Your AWS session token

### Step 2: Update Workflow File

Edit `.github/workflows/ci-cd.yml`:

```yaml
env:
  PYTHON_VERSION: '3.11'
  DOCKER_IMAGE: YOUR_DOCKERHUB_USERNAME/itemsapi  # Change this!
  AWS_REGION: us-east-1
```

**Example**:
```yaml
env:
  PYTHON_VERSION: '3.11'
  DOCKER_IMAGE: raghavkabra7/itemsapi
  AWS_REGION: us-east-1
```

### Step 3: Commit and Push Changes

```bash
# Add changes
git add .github/workflows/ci-cd.yml

# Commit
git commit -m "Update Docker Hub username in CI/CD workflow"

# Push
git push origin main
```

### Step 4: Verify CI/CD Pipeline

1. Go to your GitHub repository
2. Click **Actions** tab
3. You should see a workflow run starting
4. Click on the run to see details
5. Wait for all jobs to complete (✅ green checkmark)

**Pipeline Stages:**
1. ✅ Lint - Code quality checks
2. ✅ Test - Unit/integration tests with coverage
3. ✅ Build & Push - Docker image built and pushed to Docker Hub
4. 💤 Deploy - Disabled (manual deployment)

---

## AWS & Kubernetes Setup

### Step 1: Get AWS Credentials

**Option A: AWS Account (Recommended)**
1. Go to AWS Console: https://console.aws.amazon.com/
2. Click your username → **Security credentials**
3. Scroll to **Access keys** → **Create access key**
4. Choose **Command Line Interface (CLI)**
5. Download/copy:
   - Access Key ID
   - Secret Access Key

**Option B: AWS Academy/Learning Account**
1. Go to your AWS Academy portal
2. Click **AWS Details**
3. Copy credentials (Access Key, Secret Key, Session Token)

### Step 2: Configure AWS CLI

```bash
# Configure AWS credentials
aws configure

# Enter when prompted:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json
```

**For temporary credentials (AWS Academy):**
```bash
# Set environment variables
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
export AWS_SESSION_TOKEN=YOUR_SESSION_TOKEN

# Verify credentials work
aws sts get-caller-identity
```

### Step 3: Create EKS Cluster

```bash
# Make script executable
chmod +x scripts/setup-aws.sh

# Run setup script (takes 15-20 minutes)
./scripts/setup-aws.sh
```

**Follow the prompts:**
- Create test cluster? → `yes`
- Create production cluster? → `yes` (or `no` if you want only test)
- Create ECR repository? → `no` (we're using Docker Hub)
- Create RDS PostgreSQL? → `no` (using PostgreSQL in Kubernetes)

**Manual cluster creation (alternative):**
```bash
# Create test cluster
eksctl create cluster \
  --name itemsapi-test-cluster \
  --region us-east-1 \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3

# Install EBS CSI driver (required for persistent storage)
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster itemsapi-test-cluster \
  --region us-east-1 \
  --force
```

### Step 4: Verify Cluster Access

```bash
# Update kubeconfig
aws eks update-kubeconfig --name itemsapi-test-cluster --region us-east-1

# Verify access
kubectl get nodes

# Should show 2 nodes in Ready status
```

### Step 5: Update Kubernetes Manifests

Edit these files and replace Docker Hub username:

**File: `kubernetes/test/app-deployment.yaml`**
```yaml
containers:
- name: fastapi-app
  image: YOUR_DOCKERHUB_USERNAME/itemsapi:latest  # Change this!
```

**File: `kubernetes/prod/app-deployment.yaml`**
```yaml
containers:
- name: fastapi-app
  image: YOUR_DOCKERHUB_USERNAME/itemsapi:latest  # Change this!
```

**File: `scripts/deploy-test.sh`**
```bash
DOCKER_IMAGE="YOUR_DOCKERHUB_USERNAME/itemsapi:latest"  # Change this!
```

**File: `scripts/deploy-prod.sh`**
```bash
DOCKER_IMAGE="YOUR_DOCKERHUB_USERNAME/itemsapi:latest"  # Change this!
```

Commit changes:
```bash
git add kubernetes/ scripts/
git commit -m "Update Docker Hub username in Kubernetes manifests"
git push origin main
```

---

## Deploy Application

### Step 1: Ensure Latest Docker Image is Built

```bash
# The CI/CD pipeline automatically builds and pushes the image
# Verify on Docker Hub: https://hub.docker.com/r/YOUR_USERNAME/itemsapi

# Or trigger a build by pushing any change:
git commit --allow-empty -m "Trigger Docker build"
git push origin main

# Wait for CI/CD to complete (check GitHub Actions)
```

### Step 2: Deploy to Kubernetes

```bash
# Make sure you're connected to the cluster
aws eks update-kubeconfig --name itemsapi-test-cluster --region us-east-1

# Deploy using script
./scripts/deploy-test.sh

# Or deploy manually:
kubectl apply -f kubernetes/test/namespace.yaml
kubectl apply -f kubernetes/test/configmap.yaml
kubectl apply -f kubernetes/test/secret.yaml
kubectl apply -f kubernetes/test/postgres-deployment.yaml
kubectl apply -f kubernetes/test/app-deployment.yaml
```

### Step 3: Wait for Deployment

```bash
# Watch deployment progress
kubectl get pods -n itemsapi-test -w

# Wait until all pods show Running status (Ctrl+C to stop watching)

# Check deployment status
kubectl get pods -n itemsapi-test
kubectl get svc -n itemsapi-test
```

### Step 4: Get Application URL

```bash
# Get LoadBalancer URL
kubectl get svc itemsapi-service -n itemsapi-test

# Copy the EXTERNAL-IP (ends with .elb.amazonaws.com)
```

Example output:
```
NAME               TYPE           EXTERNAL-IP
itemsapi-service   LoadBalancer   ad3d84d26d2b44f36a8104c43df88de9-227397310.us-east-1.elb.amazonaws.com
```

---

## Access Your Application

### API Documentation (Best Way)

Open in browser:
```
http://YOUR_LOADBALANCER_URL/docs
```

**Example**:
```
http://ad3d84d26d2b44f36a8104c43df88de9-227397310.us-east-1.elb.amazonaws.com/docs
```

### Test with cURL

```bash
# Set your LoadBalancer URL
ENDPOINT="YOUR_LOADBALANCER_URL"

# Health check
curl http://${ENDPOINT}/health

# Get all items
curl http://${ENDPOINT}/items

# Create an item
curl -X POST "http://${ENDPOINT}/items" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "Gaming laptop",
    "price": 1500.00,
    "quantity": 5
  }'
```

### Available Endpoints

- `GET /health` - Health check
- `GET /items` - List all items
- `POST /items` - Create new item
- `GET /items/{id}` - Get item by ID
- `PUT /items/{id}` - Update item
- `DELETE /items/{id}` - Delete item
- `GET /docs` - Interactive API documentation (Swagger UI)
- `GET /redoc` - Alternative documentation

---

## Troubleshooting

### Docker Issues

**Problem: Docker daemon not running**
```bash
# Start Docker Desktop
open -a Docker

# Wait 30 seconds, then verify
docker ps
```

**Problem: Port 8000 already in use**
```bash
# Stop conflicting service
docker-compose down

# Or change the port in docker-compose.yml
```

### CI/CD Issues

**Problem: Workflow not running**
1. Check `.github/workflows/ci-cd.yml` exists
2. Go to repository Settings → Actions → Enable Actions
3. Push a commit to trigger workflow

**Problem: Docker login failed**
1. Verify `DOCKER_USERNAME` secret is your Docker Hub username (not email)
2. Verify `DOCKER_PASSWORD` is the access token (not your password)
3. Check token has Read, Write, Delete permissions

**Problem: Tests failing**
```bash
# Run tests locally
python -m pytest tests/ -v

# Check coverage
pytest tests/ --cov=app --cov-report=term-missing
```

### Kubernetes Issues

**Problem: Pods stuck in Pending**
```bash
# Check pod details
kubectl describe pod POD_NAME -n itemsapi-test

# Common fix: EBS CSI driver not installed
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster itemsapi-test-cluster \
  --region us-east-1 \
  --force
```

**Problem: PostgreSQL CrashLoopBackOff**
```bash
# Check logs
kubectl logs -l app=postgres -n itemsapi-test

# Common issue: EBS volume has lost+found directory
# Fix: Ensure PGDATA uses subdirectory (already configured)
```

**Problem: Can't access LoadBalancer URL**
```bash
# Wait 2-3 minutes for AWS LoadBalancer to provision
# Check service status
kubectl get svc -n itemsapi-test

# If EXTERNAL-IP shows <pending>, wait longer
# If it shows <none>, check service type is LoadBalancer
```

### AWS Permission Issues

**Problem: "AccessDeniedException" in CI/CD**
- AWS session policies may block EKS access from GitHub Actions
- Solution: Deploy manually from local terminal (credentials work locally)

**Problem: AWS credentials expired**
```bash
# Verify credentials
aws sts get-caller-identity

# If expired, get new credentials from AWS
# For temporary credentials, update environment variables
```

### Updating Application

**After making code changes:**

```bash
# 1. Commit and push
git add .
git commit -m "Your changes description"
git push origin main

# 2. CI/CD automatically builds new Docker image

# 3. Deploy manually
kubectl set image deployment/itemsapi-app \
  fastapi-app=YOUR_DOCKERHUB_USERNAME/itemsapi:latest \
  -n itemsapi-test

# 4. Verify rollout
kubectl rollout status deployment/itemsapi-app -n itemsapi-test
```

---

## Cost Management

### AWS Resources Cost (Approximate)

**EKS Cluster:**
- Control Plane: $0.10/hour per cluster
- EC2 Nodes (t3.medium): $0.0416/hour per node
- EBS Volumes: $0.10/GB-month

**Est. Total: ~$0.45/hour or ~$11/day with 2-node test cluster**

### Delete Resources When Done

```bash
# Delete test cluster (saves ~$5-6/day)
eksctl delete cluster --name itemsapi-test-cluster --region us-east-1

# Delete production cluster (if created)
eksctl delete cluster --name itemsapi-prod-cluster --region us-east-1

# Verify deletion
eksctl get cluster --region us-east-1
```

---

## Quick Reference Commands

### Local Development
```bash
docker-compose up -d              # Start services
docker-compose down               # Stop services
docker-compose logs -f app        # View logs
curl http://localhost:8000/health # Test locally
```

### Git Commands
```bash
git add .                         # Stage changes
git commit -m "message"           # Commit changes
git push origin main              # Push to GitHub
git status                        # Check status
```

### AWS Commands
```bash
aws sts get-caller-identity       # Verify credentials
aws eks list-clusters             # List EKS clusters
aws eks update-kubeconfig --name CLUSTER --region REGION  # Configure kubectl
```

### Kubernetes Commands
```bash
kubectl get pods -n itemsapi-test             # List pods
kubectl get svc -n itemsapi-test              # List services
kubectl describe pod POD_NAME -n itemsapi-test # Pod details
kubectl logs POD_NAME -n itemsapi-test        # View logs
kubectl rollout status deployment/itemsapi-app -n itemsapi-test  # Deployment status
```

### Deploy Update
```bash
kubectl set image deployment/itemsapi-app \
  fastapi-app=YOUR_USERNAME/itemsapi:latest \
  -n itemsapi-test
```

---

## Project Structure

```
devops-fastapi-project/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # CI/CD pipeline configuration
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI application
│   ├── models.py               # Database models
│   ├── database.py             # Database connection
│   └── config.py               # Configuration
├── tests/
│   ├── test_main.py            # API tests
│   ├── test_models.py          # Model tests
│   └── conftest.py             # Test fixtures
├── kubernetes/
│   ├── test/                   # Test environment configs
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── postgres-deployment.yaml
│   │   └── app-deployment.yaml
│   └── prod/                   # Production environment configs
│       └── ...
├── scripts/
│   ├── setup-aws.sh            # AWS infrastructure setup
│   ├── deploy-test.sh          # Deploy to test
│   ├── deploy-prod.sh          # Deploy to production
│   ├── monitor.sh              # Monitoring
│   └── rollback.sh             # Rollback deployment
├── docker-compose.yml          # Local development
├── Dockerfile                  # Container image
├── requirements.txt            # Python dependencies
├── requirements-dev.txt        # Development dependencies
├── pytest.ini                  # Test configuration
└── README.md                   # Project documentation
```

---

## Support & Resources

### Documentation
- FastAPI: https://fastapi.tiangolo.com/
- Docker: https://docs.docker.com/
- Kubernetes: https://kubernetes.io/docs/
- AWS EKS: https://docs.aws.amazon.com/eks/

### Tools
- GitHub Actions: https://docs.github.com/actions
- eksctl: https://eksctl.io/
- kubectl: https://kubernetes.io/docs/reference/kubectl/

---

## Summary

You now have:
1. ✅ FastAPI application running on Kubernetes (AWS EKS)
2. ✅ Complete CI/CD pipeline (GitHub Actions)
3. ✅ Automated Docker image builds
4. ✅ PostgreSQL database with persistent storage
5. ✅ LoadBalancer for public access
6. ✅ Horizontal Pod Autoscaling (HPA)
7. ✅ Health checks and smoke tests

**Your application is production-ready!** 🚀

---

**Created:** March 1, 2026  
**Project:** DevOps FastAPI with Complete CI/CD Pipeline  
**Author:** Setup Guide for Fresh Installation
