# DevOps Learning Guide

Yeh guide har concept ko detail me explain karti hai. Har section padho aur samjho **kyun** yeh approach use kar rahe hain.

## 📖 Table of Contents
1. [DevOps Kya Hai?](#devops-kya-hai)
2. [Containers & Docker](#containers--docker)
3. [Infrastructure as Code (Terraform)](#infrastructure-as-code)
4. [CI/CD Pipelines](#cicd-pipelines)
5. [AWS Services](#aws-services)
6. [Security Best Practices](#security-best-practices)
7. [Monitoring & Observability](#monitoring--observability)

---

## DevOps Kya Hai?

### Definition
DevOps = Development + Operations. Yeh ek culture hai jisme developers aur operations teams together kaam karte hain to:
- **Faster** releases (weeks ki jagah hours)
- **Reliable** deployments (no manual errors)
- **Automated** everything (testing, deployment, monitoring)

### Key Principles
1. **Automation**: Manual work = errors. Automate testing, builds, deployments.
2. **Infrastructure as Code**: Servers ko code ki tarah manage karo (version control, review, test).
3. **Continuous Integration/Deployment**: Har code change automatically test aur deploy ho.
4. **Monitoring**: Production me kya ho raha hai, real-time jaano.

---

## Containers & Docker

### Problem Docker Solves
**"Mere machine pe to chal raha tha!"** - DevOps ka sabse bada dushman.

Traditional approach:
```
Developer's laptop → Staging server → Production server
(Python 3.9)        (Python 3.8)      (Python 3.7)
                    ❌ Different dependencies = bugs
```

Docker approach:
```
Container image (Python 3.9 + dependencies) →
  Run same image everywhere ✅
```

### Docker Concepts

#### 1. Image
Blueprint/template. Read-only. Contains:
- OS (Alpine/Ubuntu)
- Runtime (Node.js/Python)
- Your code
- Dependencies

```dockerfile
FROM node:20-alpine          # Base OS + Node.js
WORKDIR /app                 # Working directory
COPY package*.json ./        # Copy dependencies first (caching!)
RUN npm ci --only=production # Install deps
COPY . .                     # Copy code
CMD ["node", "server.js"]    # Start command
```

#### 2. Container
Running instance of an image. Isolated process with its own:
- Filesystem
- Network
- Process space

```bash
docker build -t myapp:v1 .        # Create image
docker run -p 3000:3000 myapp:v1  # Run container
```

#### 3. Multi-stage Builds
Problem: Build dependencies bloat image size.

Solution:
```dockerfile
# Stage 1: Build
FROM node:20 AS builder
WORKDIR /app
COPY . .
RUN npm install && npm run build

# Stage 2: Production (only runtime deps)
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/server.js"]
# Result: 100MB instead of 500MB!
```

### Docker Compose
Local development me multiple containers manage karne ke liye:

```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports: ["3000:3000"]
    environment:
      - NODE_ENV=development
  frontend:
    build: ./frontend
    ports: ["5173:5173"]
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
```

**One command**: `docker-compose up` → sab kuch start!

---

## Infrastructure as Code

### Why Terraform?
Manual AWS Console clicks = problems:
- Kya changes kiye? (No history)
- Dusre regions me replicate kaise karein?
- Team collaboration kaise?

Terraform = Infrastructure ko code ki tarah treat karo!

### Core Concepts

#### 1. Providers
Cloud platform connection:
```hcl
provider "aws" {
  region = "us-east-1"
}
```

#### 2. Resources
Actual infrastructure components:
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "devops-vpc"
  }
}
```

#### 3. State
Terraform tracks kya create hua hai. **Critical file**: `terraform.tfstate`
- Remote me store karo (S3 + DynamoDB for locking)
- Never commit to git!

#### 4. Modules
Reusable infrastructure components:
```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  environment = "dev"
}
```

### Terraform Workflow
```bash
terraform init      # Download providers
terraform plan      # Preview changes (dry run)
terraform apply     # Apply changes
terraform destroy   # Cleanup (careful!)
```

**Key Rule**: Plan → Review → Apply. Never directly apply!

---

## CI/CD Pipelines

### Continuous Integration (CI)
Har code commit pe automatically:
1. Code lint (eslint, prettier)
2. Run tests
3. Build application
4. Build Docker image
5. Scan for vulnerabilities
6. Push to registry (ECR)

### Continuous Deployment (CD)
After CI passes:
1. Deploy to staging environment
2. Run integration tests
3. Deploy to production (with approval)
4. Health checks
5. Rollback if issues

### GitHub Actions Example
```yaml
name: CI Pipeline
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test
      - run: npm run build
      
      - name: Build Docker image
        run: docker build -t app:${{ github.sha }} .
      
      - name: Push to ECR
        # ... AWS authentication + push
```

### Benefits
- **Fast feedback**: 5 minutes me pata chal jaye agar code broken hai
- **Consistent**: Har build same environment me
- **Safe**: Manual deployment errors = 0

---

## AWS Services

### VPC (Virtual Private Cloud)
Apna private network AWS me:
```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24)  → Internet access
│   └── Load Balancer
└── Private Subnet (10.0.2.0/24) → No direct internet
    └── ECS Tasks (your app)
```

**Why?**: Security! Backend ko direct internet access nahi chahiye.

### ECR (Elastic Container Registry)
Docker Hub ki tarah, but private. Docker images store karne ke liye.

```bash
# Login
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

# Push
docker tag app:v1 <account>.dkr.ecr.us-east-1.amazonaws.com/app:v1
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/app:v1
```

### ECS (Elastic Container Service)
Docker containers run karne ke liye. Do modes:
1. **EC2**: You manage servers
2. **Fargate**: AWS manages servers (we use this!)

**Task Definition**: Container ka blueprint (which image, CPU, memory, environment variables)
**Service**: Ensures X tasks always running

### ALB (Application Load Balancer)
Traffic distribute karta hai multiple containers me:
```
User → ALB (port 80/443) → Target Group → ECS Tasks
                                         (health checks)
```

Health checks fail = automatic replacement!

### Secrets Manager
API keys, passwords safely store karo. Features:
- Encryption at rest
- Automatic rotation
- Audit logs (who accessed what)
- Version history

```bash
# Store secret
aws secretsmanager create-secret --name prod/api-key --secret-string "value"

# Retrieve in code
const secret = await secretsManager.getSecretValue({ SecretId: 'prod/api-key' }).promise();
```

---

## Security Best Practices

### 1. Never Commit Secrets
**Wrong:**
```js
const API_KEY = "sk-1234567890";  // ❌ Committed to git
```

**Right:**
```js
const API_KEY = process.env.API_KEY;  // ✅ From environment/secrets manager
```

### 2. Use IAM Roles (Not Access Keys)
**Wrong:**
```yaml
env:
  AWS_ACCESS_KEY_ID: AKIA...      # ❌ Static keys
  AWS_SECRET_ACCESS_KEY: xxx
```

**Right:**
```yaml
# GitHub Actions OIDC
permissions:
  id-token: write  # Get temporary credentials
# ... assume role via OIDC, no static keys!
```

### 3. Principle of Least Privilege
Give minimum required permissions:
```json
{
  "Effect": "Allow",
  "Action": ["s3:GetObject"],        // Only read
  "Resource": ["arn:aws:s3:::bucket/path/*"]  // Only this path
}
```

### 4. Network Security
- Public subnets: Only load balancers
- Private subnets: Application containers
- Security groups: Firewall rules (allow port 3000 only from ALB)

### 5. Image Scanning
```bash
docker scan myapp:v1  # Scan for CVEs
trivy image myapp:v1  # Another scanner
```

Fix vulnerabilities before production!

---

## Monitoring & Observability

### Logs
Application output ko centralize karo:
```js
// Application logs
console.log('User logged in', { userId: 123 });
// → CloudWatch Logs → Search, filter, alert
```

### Metrics
Quantitative data:
- Request count
- Response time (p50, p95, p99)
- Error rate
- CPU/Memory usage

### Alerts
Proactive notifications:
```
IF error_rate > 5% for 5 minutes
THEN notify on-call engineer via PagerDuty
```

### Dashboards
Visual representation:
- Request rate graph
- Error rate trend
- Latency histogram

### CloudWatch Key Concepts
1. **Log Groups**: Backend logs, frontend logs separate
2. **Metrics**: Custom metrics (business KPIs)
3. **Alarms**: Automated responses (scale up/notify)
4. **Dashboards**: Single pane of glass

---

## Common Pitfalls & Solutions

### Pitfall 1: Large Docker Images
**Problem**: 2GB image = slow deployments
**Solution**: 
- Multi-stage builds
- Use alpine base images
- .dockerignore file

### Pitfall 2: Secrets in Git History
**Problem**: Once committed, secrets exposed forever
**Solution**:
- git-secrets pre-commit hook
- BFG Repo-Cleaner to remove from history
- Rotate secrets immediately

### Pitfall 3: Terraform State Conflicts
**Problem**: Two people apply simultaneously = corruption
**Solution**: Remote state with locking (S3 + DynamoDB)

### Pitfall 4: No Rollback Strategy
**Problem**: Bad deployment breaks production
**Solution**: 
- Blue/green deployments
- Keep previous task definition
- Automated health checks

### Pitfall 5: Ignoring Costs
**Problem**: Forgot to stop dev environment = $$$
**Solution**:
- AWS Budgets + alerts
- Tag resources (env=dev)
- Auto-shutdown scripts for non-prod

---

## Next Steps

After completing all milestones:

### Advanced Topics
1. **Kubernetes (EKS)**: More powerful than ECS
2. **Service Mesh (Istio)**: Advanced networking
3. **GitOps (ArgoCD)**: Git as source of truth
4. **Observability (Prometheus + Grafana)**: Better than CloudWatch
5. **Chaos Engineering**: Break things on purpose to learn

### Practice Projects
1. Multi-region active-active setup
2. Implement canary deployments
3. Add caching layer (Redis)
4. Database migrations in CI/CD
5. Cost optimization automation

### Certifications (Optional)
- AWS Certified Solutions Architect
- Terraform Associate
- Certified Kubernetes Administrator (CKA)

---

## Resources

### Official Docs
- [Docker Docs](https://docs.docker.com)
- [Terraform Registry](https://registry.terraform.io)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected)

### Books
- "The Phoenix Project" (DevOps novel)
- "Site Reliability Engineering" (Google SRE)

### Communities
- r/devops
- AWS re:Post
- HashiCorp Community Forum

---

**Remember**: DevOps is about continuous improvement. Mistakes karega, seekhega, aur better banega! 🚀
