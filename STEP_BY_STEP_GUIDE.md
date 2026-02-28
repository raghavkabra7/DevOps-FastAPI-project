# 🚀 Step-by-Step Beginner's Guide

## Complete Guide from Zero to Deployment

This guide will walk you through **every single step** to run this project locally, set up CI/CD, and deploy to AWS.

---

## 📋 Table of Contents

1. [Run Locally with Docker (Easiest - Start Here!)](#step-1-run-locally-with-docker)
2. [Set Up GitHub Repository](#step-2-set-up-github-repository)
3. [Get Docker Hub Credentials](#step-3-get-docker-hub-credentials)
4. [Get AWS Credentials](#step-4-get-aws-credentials)
5. [Configure GitHub Secrets](#step-5-configure-github-secrets)
6. [Set Up AWS EKS (Optional - Advanced)](#step-6-set-up-aws-eks-optional)
7. [Deploy Using CI/CD](#step-7-deploy-using-cicd)
8. [Verify Everything Works](#step-8-verify-everything-works)

---

## ⭐ STEP 1: Run Locally with Docker

**This is the easiest way to start! Do this first to see the project working.**

### 1.1 Check Prerequisites

Open Terminal and check if you have Docker:

```bash
docker --version
docker-compose --version
```

**If you see version numbers, you're good!** ✅

**If you see "command not found"**: Install Docker Desktop from https://www.docker.com/products/docker-desktop

### 1.2 Navigate to Project

```bash
cd /private/tmp/devops-fastapi-project
```

### 1.3 Start the Application

```bash
docker-compose up -d
```

This will:
- Download PostgreSQL image
- Build your FastAPI application
- Start both containers

### 1.4 Wait 30 seconds, then test

```bash
# Check if containers are running
docker-compose ps

# Test the API
curl http://localhost:8000/health
```

**Expected Output:**
```json
{
  "status": "healthy",
  "environment": "development",
  "version": "1.0.0",
  "timestamp": "2026-02-28T..."
}
```

### 1.5 View the Interactive API Documentation

Open your web browser and go to:
- **http://localhost:8000/docs** (Swagger UI - Try the APIs here!)
- **http://localhost:8000/redoc** (Alternative documentation)

### 1.6 Try Creating an Item

In the browser at http://localhost:8000/docs:
1. Click on `POST /items`
2. Click "Try it out"
3. Paste this JSON:
```json
{
  "name": "Laptop",
  "description": "Gaming laptop",
  "price": 1500.00,
  "quantity": 5
}
```
4. Click "Execute"
5. You should see a 201 response with your created item!

### 1.7 View Logs (If Something Goes Wrong)

```bash
# View all logs
docker-compose logs

# View just app logs
docker-compose logs app

# Follow logs in real-time
docker-compose logs -f app
```

### 1.8 Stop the Application

```bash
docker-compose down
```

**🎉 Congratulations! You've run the project locally!**

---

## ⭐ STEP 2: Set Up GitHub Repository

Now let's put your project on GitHub so you can use CI/CD.

### 2.1 Create GitHub Account (If You Don't Have One)

1. Go to https://github.com
2. Click "Sign up"
3. Follow the steps to create your account
4. Verify your email

### 2.2 Create a New Repository

1. Log in to GitHub
2. Click the "+" icon in the top-right corner
3. Click "New repository"
4. Fill in:
   - **Repository name**: `devops-fastapi-project`
   - **Description**: "My DevOps FastAPI project with CI/CD"
   - **Visibility**: Choose "Public" or "Private"
   - **DO NOT** check "Add README" (we already have one)
5. Click "Create repository"

### 2.3 Push Your Code to GitHub

GitHub will show you commands. Copy them or use these:

```bash
# Navigate to your project
cd /private/tmp/devops-fastapi-project

# Initialize git (if not already done)
git init

# Add all files
git add .

# Make first commit
git commit -m "Initial commit: Complete DevOps FastAPI project"

# Add your GitHub repository as remote
# Replace YOUR-USERNAME with your actual GitHub username
git remote add origin https://github.com/YOUR-USERNAME/devops-fastapi-project.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**If it asks for credentials:**
- Username: Your GitHub username
- Password: **Use a Personal Access Token (NOT your GitHub password)**

### 2.4 Create GitHub Personal Access Token (PAT)

1. Go to GitHub Settings → Click your profile picture → Settings
2. Scroll down and click **"Developer settings"** (bottom left)
3. Click **"Personal access tokens"** → **"Tokens (classic)"**
4. Click **"Generate new token"** → **"Generate new token (classic)"**
5. Give it a name: `DevOps Project Token`
6. Select scopes:
   - ✅ `repo` (all)
   - ✅ `workflow`
   - ✅ `write:packages`
7. Click **"Generate token"**
8. **COPY THE TOKEN IMMEDIATELY** (you won't see it again!)
9. Use this token as your password when pushing to GitHub

### 2.5 Verify Upload

1. Go to https://github.com/YOUR-USERNAME/devops-fastapi-project
2. You should see all your files!

**🎉 Your code is now on GitHub!**

---

## ⭐ STEP 3: Get Docker Hub Credentials

Docker Hub is where we'll store your Docker images.

### 3.1 Create Docker Hub Account

1. Go to https://hub.docker.com
2. Click "Sign Up"
3. Create your account
4. Verify your email

### 3.2 Find Your Docker Username

1. Log in to Docker Hub
2. Your username is in the top-right corner (or in the URL: hub.docker.com/u/**YOUR-USERNAME**)
3. **Write it down:** `_________________`

### 3.3 Create Access Token

1. In Docker Hub, click your username → **"Account Settings"**
2. Click **"Security"** (left sidebar)
3. Click **"New Access Token"**
4. Fill in:
   - **Description**: `GitHub Actions CI/CD`
   - **Permissions**: Select **"Read, Write, Delete"**
5. Click **"Generate"**
6. **COPY THE TOKEN** (you won't see it again!)
7. **Save it somewhere safe:** `_________________`

**You now have:**
- Docker Username: `_________________`
- Docker Token: `_________________`

---

## ⭐ STEP 4: Get AWS Credentials

AWS is where we'll deploy the application in production.

### 4.1 Create AWS Account (If You Don't Have One)

1. Go to https://aws.amazon.com
2. Click "Create an AWS Account"
3. Follow the steps (you'll need a credit card)
4. **Note:** You get free tier for 12 months, but EKS costs ~$0.10/hour

### 4.2 Log in to AWS Console

1. Go to https://console.aws.amazon.com
2. Sign in with your account

### 4.3 Create IAM User for GitHub Actions

1. In AWS Console, search for **"IAM"** in the top search bar
2. Click **"Users"** (left sidebar)
3. Click **"Create user"**
4. **User name**: `github-actions-deployer`
5. Click **"Next"**
6. Select **"Attach policies directly"**
7. Search and select these policies:
   - ✅ `AmazonEKSClusterPolicy`
   - ✅ `AmazonEKSWorkerNodePolicy`
   - ✅ `AmazonEC2ContainerRegistryPowerUser`
   - ✅ `AmazonEKS_CNI_Policy`
   - Or just use: ✅ `AdministratorAccess` (easier but less secure)
8. Click **"Next"** → **"Create user"**

### 4.4 Create Access Keys

1. Click on the user you just created: `github-actions-deployer`
2. Click **"Security credentials"** tab
3. Scroll down to **"Access keys"**
4. Click **"Create access key"**
5. Select **"Command Line Interface (CLI)"**
6. Check the confirmation box
7. Click **"Next"** → Add description: `GitHub Actions` → **"Create access key"**
8. **YOU WILL SEE TWO THINGS:**
   - **Access key ID**: `AKIA...` (starts with AKIA)
   - **Secret access key**: `wJal...` (long random string)
9. **COPY BOTH** and save them:
   - AWS Access Key ID: `_________________`
   - AWS Secret Access Key: `_________________`
10. Click **"Done"**

**⚠️ IMPORTANT:** Keep these secret! Don't share them or commit them to git!

---

## ⭐ STEP 5: Configure GitHub Secrets

Now we'll add all those credentials to GitHub so the CI/CD pipeline can use them.

### 5.1 Go to Repository Settings

1. Go to your GitHub repository: https://github.com/YOUR-USERNAME/devops-fastapi-project
2. Click **"Settings"** tab (top of the page)
3. In the left sidebar, click **"Secrets and variables"**
4. Click **"Actions"**

### 5.2 Add Docker Hub Secrets

Click **"New repository secret"** and add these **ONE BY ONE**:

#### Secret 1:
- **Name**: `DOCKER_USERNAME`
- **Value**: Your Docker Hub username (from Step 3.2)
- Click "Add secret"

#### Secret 2:
- **Name**: `DOCKER_PASSWORD`
- **Value**: Your Docker Hub token (from Step 3.3)
- Click "Add secret"

### 5.3 Add AWS Secrets

#### Secret 3:
- **Name**: `AWS_ACCESS_KEY_ID`
- **Value**: Your AWS Access Key ID (from Step 4.4)
- Click "Add secret"

#### Secret 4:
- **Name**: `AWS_SECRET_ACCESS_KEY`
- **Value**: Your AWS Secret Access Key (from Step 4.4)
- Click "Add secret"

### 5.4 Add Optional SonarQube Secrets (Skip for Now)

You can skip these unless you're using SonarQube:
- `SONAR_TOKEN`
- `SONAR_HOST_URL`

### 5.5 Verify Secrets Are Added

You should see 4 secrets:
- ✅ DOCKER_USERNAME
- ✅ DOCKER_PASSWORD
- ✅ AWS_ACCESS_KEY_ID
- ✅ AWS_SECRET_ACCESS_KEY

**🎉 GitHub Secrets are configured!**

---

## ⭐ STEP 6: Update Configuration Files

Before the CI/CD can work, we need to update some configuration with YOUR information.

### 6.1 Update Docker Image Name

1. In your local project, open this file: `.github/workflows/ci-cd.yml`
2. Find line 11: `DOCKER_IMAGE: your-dockerhub-username/itemsapi`
3. Replace `your-dockerhub-username` with YOUR Docker Hub username
4. Save the file

**Example:**
```yaml
DOCKER_IMAGE: johnsmith/itemsapi  # If your username is johnsmith
```

### 6.2 Update Kubernetes Manifests

#### Update Test Environment:
1. Open: `kubernetes/test/app-deployment.yaml`
2. Find line 25: `image: your-dockerhub-username/itemsapi:latest`
3. Replace `your-dockerhub-username` with YOUR Docker Hub username
4. Save

#### Update Production Environment:
1. Open: `kubernetes/prod/app-deployment.yaml`
2. Find line 26: `image: your-dockerhub-username/itemsapi:latest`
3. Replace `your-dockerhub-username` with YOUR Docker Hub username
4. Save

### 6.3 Commit and Push Changes

```bash
cd /private/tmp/devops-fastapi-project

git add .
git commit -m "Update Docker image names with my Docker Hub username"
git push origin main
```

**🎉 Configuration is updated!**

---

## ⭐ STEP 7: Set Up AWS EKS (Optional - Advanced)

**⚠️ WARNING:** This will create resources that cost money (~$0.10/hour for EKS + EC2 costs)

**Option A: Skip for Now** - You can test the CI/CD pipeline without deploying to AWS. The build and test stages will still run.

**Option B: Set Up AWS** - Follow these steps:

### 7.1 Install Required Tools

#### Install AWS CLI:
```bash
# macOS
brew install awscli

# Or download from: https://aws.amazon.com/cli/
```

#### Install eksctl:
```bash
# macOS
brew install eksctl

# Or download from: https://eksctl.io/installation/
```

#### Install kubectl:
```bash
# macOS
brew install kubectl

# Or download from: https://kubernetes.io/docs/tasks/tools/
```

### 7.2 Configure AWS CLI

```bash
aws configure
```

When prompted, enter:
- **AWS Access Key ID**: (from Step 4.4)
- **AWS Secret Access Key**: (from Step 4.4)
- **Default region**: `us-east-1` (or your preferred region)
- **Default output format**: `json`

### 7.3 Create Test EKS Cluster

```bash
eksctl create cluster \
  --name itemsapi-test-cluster \
  --region us-east-1 \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
```

**This will take 15-20 minutes!** ☕ Go get coffee.

### 7.4 Create Production EKS Cluster

```bash
eksctl create cluster \
  --name itemsapi-prod-cluster \
  --region us-east-1 \
  --node-type t3.large \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 5 \
  --managed
```

**This will also take 15-20 minutes!** ☕

### 7.5 Install Metrics Server (for Auto-scaling)

```bash
# For test cluster
aws eks update-kubeconfig --name itemsapi-test-cluster --region us-east-1
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For production cluster
aws eks update-kubeconfig --name itemsapi-prod-cluster --region us-east-1
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 7.6 Update CI/CD with Cluster Names

If you used different cluster names, update `.github/workflows/ci-cd.yml`:
- Line 153: Test cluster name
- Line 197: Production cluster name

**🎉 AWS EKS is ready!** (But this is optional - see Option A)

---

## ⭐ STEP 8: Deploy Using CI/CD

Now the fun part - automatic deployment!

### 8.1 Create a Develop Branch

```bash
cd /private/tmp/devops-fastapi-project

# Create and switch to develop branch
git checkout -b develop

# Make a small change to trigger the pipeline
echo "# Test deployment" >> README.md

# Commit and push
git add .
git commit -m "Test: Trigger CI/CD pipeline"
git push origin develop
```

### 8.2 Watch the GitHub Actions Pipeline

1. Go to your GitHub repository
2. Click the **"Actions"** tab (top of the page)
3. You should see a workflow running called "CI/CD Pipeline"
4. Click on it to watch the progress

**You'll see these stages run:**
1. ✅ Lint (code quality)
2. ✅ Test (runs all tests)
3. ⏭️ SonarQube (skipped if not configured)
4. ✅ Build & Push (builds Docker image)
5. ✅ Deploy Test (if AWS is set up)
6. ⏭️ Deploy Production (only runs on main branch)

### 8.3 Understanding What Happens

**On `develop` branch:**
- ✅ Runs tests
- ✅ Builds Docker image
- ✅ Deploys to TEST environment (if AWS configured)

**On `main` branch:**
- ✅ Runs tests
- ✅ Builds Docker image
- ✅ Deploys to PRODUCTION environment (if AWS configured)

### 8.4 Check Docker Hub

1. Go to https://hub.docker.com
2. Click "Repositories"
3. You should see your `itemsapi` repository
4. Click on it to see the pushed images

**🎉 Your first automated deployment!**

---

## ⭐ STEP 9: Verify Everything Works

### 9.1 Local Verification

```bash
# Start locally
docker-compose up -d

# Test health
curl http://localhost:8000/health

# Test creating an item
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Item","price":99.99,"quantity":10}'

# Test getting items
curl http://localhost:8000/items

# Stop
docker-compose down
```

### 9.2 GitHub Actions Verification

1. Go to GitHub Actions tab
2. All checkmarks should be green ✅
3. If something is red ❌, click on it to see the error

### 9.3 AWS Verification (If You Set Up AWS)

```bash
# Connect to test cluster
aws eks update-kubeconfig --name itemsapi-test-cluster --region us-east-1

# Check pods
kubectl get pods -n itemsapi-test

# Check service
kubectl get svc -n itemsapi-test

# Get the URL
kubectl get svc itemsapi-service -n itemsapi-test -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test health (replace <URL> with the URL from above)
curl http://<URL>/health
```

---

## 🎯 Common Issues and Solutions

### Issue 1: "docker: command not found"
**Solution:** Install Docker Desktop from https://www.docker.com/products/docker-desktop

### Issue 2: "error: failed to push some refs to github"
**Solution:** Make sure you're using a Personal Access Token (not your password) when pushing

### Issue 3: GitHub Actions fails on "Login to Docker Hub"
**Solution:** 
- Check that Docker Hub secrets are correct in GitHub Settings
- Make sure your Docker Hub token has "Read, Write, Delete" permissions

### Issue 4: "Cannot connect to the Docker daemon"
**Solution:** 
- Start Docker Desktop application
- Wait for it to fully start (look for green icon)

### Issue 5: AWS deployment fails
**Solution:**
- Make sure AWS credentials are correct in GitHub Secrets
- Verify EKS clusters exist: `eksctl get cluster`
- Check cluster names in `.github/workflows/ci-cd.yml` match

### Issue 6: Tests fail with database error
**Solution:** This is normal if PostgreSQL isn't running. The CI/CD pipeline will run tests with a database automatically.

---

## 📝 Quick Reference Checklist

Use this checklist to track your progress:

- [ ] Step 1: Run locally with Docker
- [ ] Step 2: Create GitHub repository
- [ ] Step 3: Get Docker Hub credentials
- [ ] Step 4: Get AWS credentials
- [ ] Step 5: Add secrets to GitHub
- [ ] Step 6: Update configuration files
- [ ] Step 7: Set up AWS EKS (optional)
- [ ] Step 8: Test CI/CD pipeline
- [ ] Step 9: Verify everything works

---

## 🎓 What You've Learned

By completing this guide, you've learned:
- ✅ How to run applications with Docker
- ✅ How to use GitHub for version control
- ✅ How to set up CI/CD with GitHub Actions
- ✅ How to configure secrets securely
- ✅ How to deploy to cloud (AWS)
- ✅ How to use Kubernetes for orchestration
- ✅ DevOps best practices

---

## 🆘 Need Help?

If you get stuck:

1. **Check the logs:**
   ```bash
   # Docker logs
   docker-compose logs app
   
   # Kubernetes logs (if using AWS)
   kubectl logs -f deployment/itemsapi-app -n itemsapi-test
   ```

2. **Check GitHub Actions:**
   - Click on the failed step
   - Read the error message
   - Google the error

3. **Common Commands:**
   ```bash
   # Stop all Docker containers
   docker-compose down
   
   # Restart everything
   docker-compose up -d --build
   
   # Check running containers
   docker ps
   
   # Check GitHub Actions status
   # Go to: github.com/YOUR-USERNAME/devops-fastapi-project/actions
   ```

---

## 🎉 Congratulations!

You've successfully set up a complete DevOps project with:
- ✅ Docker containerization
- ✅ GitHub version control
- ✅ Automated CI/CD pipeline
- ✅ Cloud deployment (optional)

**You're now a DevOps engineer!** 🚀

---

## 📚 Next Steps

1. **Make changes** to the code and watch them deploy automatically
2. **Add more features** to the API
3. **Customize** the Kubernetes configurations
4. **Add monitoring** with Prometheus/Grafana
5. **Set up a custom domain** for your API

---

**Need help? Check README.md for detailed documentation!**
