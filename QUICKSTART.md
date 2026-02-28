# 🚀 Quick Start Guide - ItemsAPI DevOps Project

Get started with the complete DevOps pipeline in minutes!

## ⚡ 5-Minute Local Setup

### Prerequisites
- Python 3.11+
- Docker Desktop
- Git

### Steps

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd devops-fastapi-project
   ```

2. **Run setup script**
   ```bash
   ./scripts/setup-local.sh
   ```

3. **Access the API**
   - API: http://localhost:8000
   - Swagger Docs: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

That's it! Your API is running locally with PostgreSQL.

---

## 🎯 Test the API

### Using curl

**Health Check:**
```bash
curl http://localhost:8000/health
```

**Create an Item:**
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

**List Items:**
```bash
curl http://localhost:8000/items
```

**Get Item by ID:**
```bash
curl http://localhost:8000/items/1
```

**Update Item:**
```bash
curl -X PUT http://localhost:8000/items/1 \
  -H "Content-Type: application/json" \
  -d '{"price": 1199.99}'
```

**Delete Item:**
```bash
curl -X DELETE http://localhost:8000/items/1
```

### Using Swagger UI
Visit http://localhost:8000/docs for an interactive API interface.

---

## 🧪 Run Tests

```bash
# Activate virtual environment
source venv/bin/activate

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html

# View coverage report
open htmlcov/index.html
```

---

## ☁️ Deploy to AWS (Complete DevOps Setup)

### Step 1: AWS Setup (One-time)

**Prerequisites:**
- AWS Account
- AWS CLI configured
- eksctl installed
- kubectl installed

**Run AWS setup script:**
```bash
./scripts/setup-aws.sh
```

This will:
- Create EKS clusters (test & production)
- Install metrics server for auto-scaling
- Optionally create ECR repository
- Provide setup completion summary

**⏰ Time: ~30-40 minutes (EKS cluster creation)**

### Step 2: Configure GitHub (One-time)

1. **Add GitHub Secrets** (Settings → Secrets and variables → Actions):
   ```
   DOCKER_USERNAME          # Your Docker Hub username
   DOCKER_PASSWORD          # Docker Hub password/token
   AWS_ACCESS_KEY_ID        # AWS access key
   AWS_SECRET_ACCESS_KEY    # AWS secret key
   SONAR_TOKEN             # Optional: SonarQube token
   SONAR_HOST_URL          # Optional: SonarQube URL
   ```

2. **Update CI/CD configuration** (`.github/workflows/ci-cd.yml`):
   - Line 10: Update Docker image name
   - Line 11: Update AWS region
   - Line 153: Update test cluster name
   - Line 216: Update prod cluster name

3. **Update Kubernetes manifests**:
   - Update Docker image in `kubernetes/test/app-deployment.yaml` (line 25)
   - Update Docker image in `kubernetes/prod/app-deployment.yaml` (line 26)

### Step 3: Deploy via CI/CD

**Option A: Automatic Deployment (Recommended)**

```bash
# Deploy to test environment
git checkout -b develop
git push origin develop

# Deploy to production
git checkout main
git merge develop
git push origin main
```

**Option B: Manual Deployment**

```bash
# Deploy to test
./scripts/deploy-test.sh

# Deploy to production
./scripts/deploy-prod.sh
```

### Step 4: Monitor Deployment

```bash
# Monitor test environment
./scripts/monitor.sh --env test

# Monitor production environment
./scripts/monitor.sh --env prod
```

### Step 5: Verify Deployment

```bash
# Get the LoadBalancer URL
kubectl get svc itemsapi-service -n itemsapi-prod

# Test health endpoint
curl http://<LOADBALANCER-URL>/health
```

---

## 🔄 Development Workflow

### Daily Development
```bash
# 1. Start local environment
docker-compose up -d

# 2. Make code changes

# 3. Run tests
pytest tests/ -v

# 4. Format code
black app/ tests/

# 5. Commit and push
git add .
git commit -m "Description of changes"
git push
```

### Branch Strategy
- `develop` → Test environment (auto-deploy)
- `main` → Production environment (auto-deploy with approval)
- `feature/*` → Development branches (tests only, no deploy)

### Release Process
```bash
# 1. Create feature branch
git checkout -b feature/new-feature develop

# 2. Develop and test
git add .
git commit -m "Add new feature"
git push origin feature/new-feature

# 3. Create Pull Request to develop
# CI/CD runs tests automatically

# 4. Merge to develop
# Automatically deploys to test environment

# 5. Test in test environment
# Run integration tests, QA verification

# 6. Merge to main
git checkout main
git merge develop
git push origin main
# Automatically deploys to production (with approval)
```

---

## 🛠️ Common Operations

### View Logs
```bash
# Local
docker-compose logs -f app

# Kubernetes (test)
kubectl logs -f deployment/itemsapi-app -n itemsapi-test

# Kubernetes (production)
kubectl logs -f deployment/itemsapi-app -n itemsapi-prod
```

### Restart Application
```bash
# Local
docker-compose restart app

# Kubernetes
kubectl rollout restart deployment/itemsapi-app -n itemsapi-prod
```

### Scale Application
```bash
# Manual scaling
kubectl scale deployment/itemsapi-app --replicas=5 -n itemsapi-prod

# Check HPA (auto-scaling)
kubectl get hpa -n itemsapi-prod
```

### Rollback Deployment
```bash
# Rollback to previous version (test)
./scripts/rollback.sh --env test

# Rollback to previous version (production)
./scripts/rollback.sh --env prod

# Rollback to specific revision
./scripts/rollback.sh --env prod --revision 3
```

### Update Application Image
```bash
# Deploy new version
kubectl set image deployment/itemsapi-app \
  fastapi-app=your-username/itemsapi:v1.1.0 \
  -n itemsapi-prod

# Monitor rollout
kubectl rollout status deployment/itemsapi-app -n itemsapi-prod
```

---

## 📊 Monitoring & Debugging

### Check Application Health
```bash
# Local
curl http://localhost:8000/health

# Production
ENDPOINT=$(kubectl get svc itemsapi-service -n itemsapi-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://${ENDPOINT}/health
```

### Check Pod Status
```bash
kubectl get pods -n itemsapi-prod
kubectl describe pod <pod-name> -n itemsapi-prod
```

### Check Resource Usage
```bash
kubectl top pods -n itemsapi-prod
kubectl top nodes
```

### Debug Pod Issues
```bash
# Get shell access
kubectl exec -it <pod-name> -n itemsapi-prod -- /bin/bash

# View recent events
kubectl get events -n itemsapi-prod --sort-by='.lastTimestamp'
```

---

## 🎬 CI/CD Pipeline Stages

The automated pipeline runs on every push:

1. **Lint** (2-3 min)
   - Black formatter check
   - Pylint code quality check

2. **Test** (3-5 min)
   - Unit tests with PostgreSQL
   - Coverage check (80% minimum)
   - Upload coverage reports

3. **SonarQube** (2-3 min) - Optional
   - Code quality analysis
   - Security vulnerability scan

4. **Build & Push** (5-7 min)
   - Build Docker image
   - Push to registry
   - Vulnerability scan (Trivy)

5. **Deploy Test** (3-5 min) - on `develop` branch
   - Deploy to test cluster
   - Smoke tests

6. **Deploy Production** (5-10 min) - on `main` branch
   - Deploy to production cluster
   - Zero-downtime rolling update
   - Smoke tests

7. **Rollback** - on failure
   - Automatic rollback
   - Restore previous version

**Total Pipeline Time:**
- Test deployment: ~15-20 minutes
- Production deployment: ~20-30 minutes

---

## 💰 Cost Estimates (AWS)

### Test Environment
- EKS Control Plane: ~$73/month
- 2x t3.medium nodes: ~$60/month
- Load Balancer: ~$16/month
- **Total: ~$150/month**

### Production Environment
- EKS Control Plane: ~$73/month
- 3x t3.large nodes: ~$180/month
- Load Balancer: ~$16/month
- **Total: ~$270/month**

### Combined Total: ~$420/month

**Cost Optimization Tips:**
- Use spot instances for non-production
- Delete test environment when not needed
- Use Fargate for variable workloads
- Implement auto-scaling to minimize idle resources

---

## 🧹 Cleanup

### Stop Local Environment
```bash
docker-compose down
docker-compose down -v  # Also remove volumes
```

### Delete AWS Resources
```bash
# Delete test cluster
eksctl delete cluster --name itemsapi-test-cluster --region us-east-1

# Delete production cluster
eksctl delete cluster --name itemsapi-prod-cluster --region us-east-1

# Delete ECR repository
aws ecr delete-repository --repository-name itemsapi --force --region us-east-1
```

---

## 🆘 Troubleshooting

### Issue: Docker Compose won't start
```bash
# Check Docker is running
docker ps

# Check logs
docker-compose logs

# Remove containers and start fresh
docker-compose down -v
docker-compose up -d
```

### Issue: Tests failing
```bash
# Ensure database is running
docker-compose ps

# Check database connection
docker-compose exec app python -c "from app.database import engine; engine.connect()"

# Re-run with verbose output
pytest tests/ -vv
```

### Issue: Kubernetes pods not starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n itemsapi-test

# Check logs
kubectl logs <pod-name> -n itemsapi-test

# Check events
kubectl get events -n itemsapi-test
```

### Issue: Cannot access LoadBalancer
```bash
# Check service
kubectl get svc itemsapi-service -n itemsapi-prod

# Wait for LoadBalancer to be provisioned (can take 2-3 minutes)
# Check AWS Console → EC2 → Load Balancers

# Verify security groups allow ingress
```

---

## 📚 Additional Resources

- [Full README](README.md) - Complete documentation
- [API Documentation](http://localhost:8000/docs) - Interactive API docs
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

---

## ✅ Next Steps

1. ✅ Set up local development environment
2. ✅ Test API locally
3. ✅ Run tests and ensure coverage
4. ✅ Set up AWS infrastructure
5. ✅ Configure GitHub secrets
6. ✅ Deploy to test environment
7. ✅ Verify test deployment
8. ✅ Deploy to production
9. ✅ Set up monitoring
10. ✅ Plan for continuous improvements

---

**Questions or Issues?**
- Check the [README](README.md) for detailed documentation
- Review logs with `./scripts/monitor.sh`
- Open an issue on GitHub

**Happy Deploying! 🚀**
