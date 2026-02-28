# 🚀 Item Management API - Complete DevOps Project

A production-ready FastAPI application demonstrating end-to-end DevOps practices including CI/CD, Docker, Kubernetes, and AWS deployment.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Testing](#testing)
- [Docker Deployment](#docker-deployment)
- [AWS Setup](#aws-setup)
- [Kubernetes Deployment](#kubernetes-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [API Documentation](#api-documentation)
- [Environment Configuration](#environment-configuration)
- [Monitoring & Logging](#monitoring--logging)

## 🎯 Project Overview

This project demonstrates a complete DevOps workflow for a Python FastAPI application with:
- **4 RESTful API endpoints** (CRUD operations for item management)
- **Comprehensive test coverage** (80%+ with pytest)
- **Multi-stage CI/CD pipeline** with GitHub Actions
- **Containerized deployment** with Docker
- **Container orchestration** with Kubernetes
- **Two environments**: Test and Production
- **AWS cloud deployment** on EKS

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Repository                       │
│                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐         │
│  │  Code    │───▶│  Tests   │───▶│   Linting    │         │
│  └──────────┘    └──────────┘    └──────────────┘         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│               GitHub Actions CI/CD Pipeline                  │
│                                                              │
│  ┌──────┐  ┌──────┐  ┌────────┐  ┌──────┐  ┌──────────┐  │
│  │ Lint │─▶│ Test │─▶│ Build  │─▶│ Push │─▶│  Deploy  │  │
│  └──────┘  └──────┘  └────────┘  └──────┘  └──────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
    ┌──────────────┐         ┌──────────────┐
    │ Test ENV     │         │  Prod ENV    │
    │ (develop)    │         │  (main)      │
    │              │         │              │
    │ AWS EKS      │         │  AWS EKS     │
    │ 2 replicas   │         │  3 replicas  │
    └──────────────┘         └──────────────┘
            │                         │
            ▼                         ▼
    ┌──────────────┐         ┌──────────────┐
    │  PostgreSQL  │         │  PostgreSQL  │
    │  (RDS/Pod)   │         │  (RDS/Pod)   │
    └──────────────┘         └──────────────┘
```

## ✨ Features

### API Endpoints
- `GET /health` - Health check endpoint
- `POST /items` - Create a new item
- `GET /items` - List all items (with pagination)
- `GET /items/{id}` - Get item by ID
- `PUT /items/{id}` - Update item by ID
- `DELETE /items/{id}` - Delete item by ID

### DevOps Features
- ✅ Multi-stage Docker builds
- ✅ Docker Compose for local development
- ✅ Kubernetes manifests for test & production
- ✅ GitHub Actions CI/CD with 7 stages
- ✅ Automated testing with pytest (80%+ coverage)
- ✅ Code quality checks (Black, Pylint)
- ✅ SonarQube integration (optional)
- ✅ Container vulnerability scanning (Trivy)
- ✅ Auto-scaling with HPA
- ✅ Zero-downtime deployments
- ✅ Automated rollback on failure

## 📦 Prerequisites

### Required Tools
- Python 3.11+
- Docker & Docker Compose
- kubectl (Kubernetes CLI)
- AWS CLI v2
- Git

### AWS Resources
- AWS Account
- EKS Cluster (Test & Production)
- ECR Repository (optional, or use Docker Hub)
- RDS PostgreSQL (optional, or use in-cluster)
- IAM User with appropriate permissions

### GitHub Secrets
Configure these secrets in your GitHub repository:
```
DOCKER_USERNAME          # Docker Hub username
DOCKER_PASSWORD          # Docker Hub password/token
AWS_ACCESS_KEY_ID        # AWS access key
AWS_SECRET_ACCESS_KEY    # AWS secret key
SONAR_TOKEN             # SonarQube token (optional)
SONAR_HOST_URL          # SonarQube server URL (optional)
```

## 🛠️ Local Development

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/devops-fastapi-project.git
cd devops-fastapi-project
```

### 2. Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements-dev.txt
```

### 4. Configure Environment
```bash
cp .env.example .env
# Edit .env with your configuration
```

### 5. Run with Docker Compose (Recommended)
```bash
docker-compose up -d
```

The API will be available at `http://localhost:8000`

### 6. Run Locally (Without Docker)
```bash
# Start PostgreSQL (using Docker)
docker run -d -p 5432:5432 \
  -e POSTGRES_DB=itemsdb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  postgres:15-alpine

# Run the application
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 🧪 Testing

### Run All Tests
```bash
pytest tests/ -v
```

### Run with Coverage
```bash
pytest tests/ --cov=app --cov-report=html --cov-report=term-missing
```

### View Coverage Report
```bash
open htmlcov/index.html
```

### Run Specific Test Classes
```bash
# Test health endpoint
pytest tests/test_main.py::TestHealthEndpoint -v

# Test CRUD operations
pytest tests/test_main.py::TestCreateItemEndpoint -v
pytest tests/test_main.py::TestUpdateItemEndpoint -v
pytest tests/test_main.py::TestDeleteItemEndpoint -v
```

### Code Quality Checks
```bash
# Format code
black app/ tests/

# Lint code
pylint app/ --fail-under=8.0
```

## 🐳 Docker Deployment

### Build Docker Image
```bash
docker build -t itemsapi:latest .
```

### Run Docker Container
```bash
docker run -d -p 8000:8000 \
  -e DATABASE_URL=postgresql://postgres:postgres@host.docker.internal:5432/itemsdb \
  itemsapi:latest
```

### Push to Docker Hub
```bash
docker tag itemsapi:latest your-username/itemsapi:latest
docker push your-username/itemsapi:latest
```

### Push to AWS ECR
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag itemsapi:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/itemsapi:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/itemsapi:latest
```

## ☁️ AWS Setup

### Step 1: Create EKS Clusters

#### Test Environment Cluster
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

#### Production Environment Cluster
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

### Step 2: Configure kubectl
```bash
# For test cluster
aws eks update-kubeconfig --name itemsapi-test-cluster --region us-east-1

# For production cluster
aws eks update-kubeconfig --name itemsapi-prod-cluster --region us-east-1
```

### Step 3: Install Metrics Server (for HPA)
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Step 4: (Optional) Create RDS PostgreSQL
```bash
aws rds create-db-instance \
  --db-instance-identifier itemsapi-prod-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password YourSecurePassword \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxxxxx \
  --db-subnet-group-name your-subnet-group \
  --publicly-accessible
```

Update the `DATABASE_URL` in Kubernetes secrets with RDS endpoint.

## ☸️ Kubernetes Deployment

### Deploy to Test Environment
```bash
# Apply all test manifests
kubectl apply -f kubernetes/test/

# Verify deployment
kubectl get pods -n itemsapi-test
kubectl get svc -n itemsapi-test

# Get LoadBalancer URL
kubectl get svc itemsapi-service -n itemsapi-test
```

### Deploy to Production Environment
```bash
# Apply all production manifests
kubectl apply -f kubernetes/prod/

# Verify deployment
kubectl get pods -n itemsapi-prod
kubectl get svc -n itemsapi-prod

# Get LoadBalancer URL
kubectl get svc itemsapi-service -n itemsapi-prod
```

### Update Application
```bash
# Update image
kubectl set image deployment/itemsapi-app \
  fastapi-app=your-username/itemsapi:v1.1.0 \
  -n itemsapi-prod

# Monitor rollout
kubectl rollout status deployment/itemsapi-app -n itemsapi-prod
```

### Rollback Deployment
```bash
# Rollback to previous version
kubectl rollout undo deployment/itemsapi-app -n itemsapi-prod

# Rollback to specific revision
kubectl rollout undo deployment/itemsapi-app --to-revision=2 -n itemsapi-prod
```

### Scale Application
```bash
# Manual scaling
kubectl scale deployment/itemsapi-app --replicas=5 -n itemsapi-prod

# HPA is already configured in manifests for auto-scaling
```

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline consists of 7 stages:

### 1. **Lint Stage** (Code Quality)
- Runs Black formatter check
- Runs Pylint with minimum score of 8.0
- Triggers on: push, pull_request

### 2. **Test Stage** (Unit & Integration Tests)
- Spins up PostgreSQL service
- Runs pytest with coverage
- Requires 80%+ coverage
- Uploads coverage reports

### 3. **SonarQube Stage** (Code Analysis)
- Analyzes code quality
- Checks security vulnerabilities
- Only runs on main branch
- Optional: requires SonarQube setup

### 4. **Build & Push Stage** (Docker)
- Builds multi-stage Docker image
- Pushes to Docker Hub/ECR
- Scans for vulnerabilities (Trivy)
- Tags: branch, SHA, latest

### 5. **Deploy Test Stage**
- Deploys to test environment
- Runs on `develop` branch
- Automatic deployment
- Runs smoke tests

### 6. **Deploy Production Stage**
- Deploys to production
- Runs on `main` branch
- Requires manual approval (GitHub environment)
- Zero-downtime rolling update
- Runs smoke tests

### 7. **Rollback Stage**
- Automatically triggers on deployment failure
- Reverts to previous stable version

### Branch Strategy
- `develop` → Deploy to Test Environment
- `main` → Deploy to Production Environment
- Pull Requests → Run tests only (no deployment)

### Pipeline Flow Diagram
```
┌─────────┐     ┌──────┐     ┌──────┐     ┌───────────┐
│  Lint   │────▶│ Test │────▶│Sonar │────▶│Build&Push │
└─────────┘     └──────┘     └──────┘     └─────┬─────┘
                                                  │
                                    ┌─────────────┴─────────────┐
                                    ▼                           ▼
                            ┌───────────────┐         ┌──────────────┐
                            │  Deploy Test  │         │ Deploy Prod  │
                            │  (develop)    │         │  (main)      │
                            └───────┬───────┘         └──────┬───────┘
                                    │                        │
                                    ▼                        ▼
                            ┌───────────────┐         ┌──────────────┐
                            │  Smoke Tests  │         │ Smoke Tests  │
                            └───────┬───────┘         └──────┬───────┘
                                    │                        │
                                    └────────┬───────────────┘
                                             ▼
                                    ┌─────────────────┐
                                    │  Rollback on    │
                                    │    Failure      │
                                    └─────────────────┘
```

## 📚 API Documentation

### Interactive API Docs
Once the application is running:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### Example API Calls

#### Health Check
```bash
curl http://localhost:8000/health
```

Response:
```json
{
  "status": "healthy",
  "environment": "development",
  "version": "1.0.0",
  "timestamp": "2026-02-28T10:00:00.000Z"
}
```

#### Create Item
```bash
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 1299.99,
    "quantity": 10
  }'
```

#### List Items
```bash
curl http://localhost:8000/items?skip=0&limit=10
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
    "price": 1199.99,
    "quantity": 15
  }'
```

#### Delete Item
```bash
curl -X DELETE http://localhost:8000/items/1
```

## ⚙️ Environment Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `APP_NAME` | Application name | Item Management API | No |
| `APP_VERSION` | Application version | 1.0.0 | No |
| `ENVIRONMENT` | Environment (development/test/production) | development | Yes |
| `DEBUG` | Debug mode | true | No |
| `DATABASE_URL` | PostgreSQL connection string | postgresql://... | Yes |
| `HOST` | Server host | 0.0.0.0 | No |
| `PORT` | Server port | 8000 | No |
| `LOG_LEVEL` | Logging level | INFO | No |

### Configuration Files
- `.env` - Local development environment
- `kubernetes/test/configmap.yaml` - Test environment config
- `kubernetes/prod/configmap.yaml` - Production environment config

## 📊 Monitoring & Logging

### Application Logs
```bash
# View application logs
kubectl logs -f deployment/itemsapi-app -n itemsapi-prod

# View logs from all pods
kubectl logs -f -l app=itemsapi -n itemsapi-prod
```

### Monitor Resources
```bash
# Check CPU and memory usage
kubectl top pods -n itemsapi-prod
kubectl top nodes

# Check HPA status
kubectl get hpa -n itemsapi-prod
```

### Health Checks
```bash
# Application health
curl http://your-loadbalancer-url/health

# Kubernetes readiness
kubectl get pods -n itemsapi-prod
```

## 🔒 Security Best Practices

- ✅ Non-root user in Docker container
- ✅ Multi-stage builds to minimize image size
- ✅ Container vulnerability scanning with Trivy
- ✅ Secrets stored in Kubernetes Secrets
- ✅ HTTPS support (configure ingress)
- ✅ Network policies (to be added)
- ✅ Pod security policies
- ⚠️ Use AWS Secrets Manager for production secrets

## 📈 Scaling & Performance

### Horizontal Pod Autoscaler (HPA)
Automatically scales based on:
- CPU utilization (70% threshold)
- Memory utilization (80% threshold)

Test scaling:
- Min replicas: 2 (test), 3 (prod)
- Max replicas: 5 (test), 10 (prod)

Production: 3-10 replicas
- Min replicas: 3
- Max replicas: 10
- CPU threshold: 60%
- Memory threshold: 70%

### Database Connection Pooling
- Pool size: 10
- Max overflow: 20
- Pre-ping enabled

## 🐛 Troubleshooting

### Common Issues

#### Pods not starting
```bash
kubectl describe pod <pod-name> -n itemsapi-test
kubectl logs <pod-name> -n itemsapi-test
```

#### Database connection errors
```bash
# Check if PostgreSQL is running
kubectl get pods -n itemsapi-test -l app=postgres

# Test connection
kubectl exec -it <pod-name> -n itemsapi-test -- bash
# Inside pod: psql -h postgres-service -U postgres -d itemsdb
```

#### LoadBalancer not getting external IP
```bash
kubectl describe svc itemsapi-service -n itemsapi-test

# Check AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer-controller
```

## 📝 Project Structure

```
devops-fastapi-project/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions CI/CD pipeline
├── app/
│   ├── __init__.py
│   ├── config.py              # Configuration management
│   ├── database.py            # Database setup
│   ├── main.py                # FastAPI application
│   └── models.py              # SQLAlchemy & Pydantic models
├── kubernetes/
│   ├── test/                  # Test environment manifests
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── postgres-deployment.yaml
│   │   └── app-deployment.yaml
│   └── prod/                  # Production environment manifests
│       ├── namespace.yaml
│       ├── configmap.yaml
│       ├── secret.yaml
│       ├── postgres-deployment.yaml
│       └── app-deployment.yaml
├── tests/
│   ├── __init__.py
│   ├── conftest.py            # Pytest fixtures
│   ├── test_main.py           # API endpoint tests
│   └── test_models.py         # Model tests
├── .dockerignore
├── .env.example               # Environment template
├── .gitignore
├── .pylintrc                  # Pylint configuration
├── docker-compose.yml         # Local development setup
├── Dockerfile                 # Multi-stage Docker build
├── pytest.ini                 # Pytest configuration
├── requirements.txt           # Production dependencies
├── requirements-dev.txt       # Development dependencies
├── sonar-project.properties   # SonarQube configuration
└── README.md                  # This file
```

## 🚦 Getting Started - Quick Guide

1. **Clone and setup locally**
   ```bash
   git clone <repo-url>
   cd devops-fastapi-project
   cp .env.example .env
   docker-compose up -d
   ```

2. **Run tests**
   ```bash
   pytest tests/ -v --cov=app
   ```

3. **Setup AWS EKS clusters**
   ```bash
   eksctl create cluster --name itemsapi-test-cluster --region us-east-1
   eksctl create cluster --name itemsapi-prod-cluster --region us-east-1
   ```

4. **Configure GitHub Secrets**
   - Add Docker Hub credentials
   - Add AWS credentials
   - Add SonarQube credentials (optional)

5. **Update CI/CD configuration**
   - Edit `.github/workflows/ci-cd.yml`
   - Update Docker image name
   - Update EKS cluster names
   - Update AWS region

6. **Deploy**
   - Push to `develop` branch → Deploys to test
   - Push to `main` branch → Deploys to production

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- Your Name - DevOps Engineer

## 🙏 Acknowledgments

- FastAPI documentation
- Kubernetes documentation
- AWS EKS documentation
- Docker best practices

---

**Happy Deploying! 🚀**

For questions or issues, please open an issue on GitHub.
