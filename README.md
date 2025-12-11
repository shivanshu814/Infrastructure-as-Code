# DevOps Learning Project

Complete production-grade project to learn DevOps from A-Z: Docker, Terraform, AWS ECS, CI/CD, monitoring, and security.

## 🎯 Project Goal

Build and deploy a full-stack application (Node.js API + React frontend) using industry-standard DevOps practices.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                Application Load Balancer              │   │
│  └──────────────┬──────────────────────┬─────────────────┘   │
│                 │                      │                      │
│       ┌─────────▼──────────┐ ┌────────▼──────────┐          │
│       │  ECS Service       │ │  ECS Service       │          │
│       │   (Backend API)    │ │   (Frontend)       │          │
│       │  Fargate Tasks     │ │  Fargate Tasks     │          │
│       └────────────────────┘ └────────────────────┘          │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         AWS Secrets Manager + CloudWatch             │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

         ┌─────────────────────────────────────┐
         │       GitHub Actions CI/CD           │
         │  Build → Test → Push ECR → Deploy   │
         └─────────────────────────────────────┘
```

## 📚 Learning Path (10 Milestones)

### ✅ Milestone 1: Local Development

- Setup Node.js API + React app
- Docker containers
- Docker Compose for local stack

### ✅ Milestone 2: Git & Security

- Proper .gitignore
- Secret management (never commit secrets!)
- Environment-based configs

### ✅ Milestone 3: CI Pipeline

- GitHub Actions
- Automated tests
- Docker image builds

### ✅ Milestone 4: AWS Basics

- ECR (container registry)
- IAM roles & policies
- Security best practices

### ✅ Milestone 5: Infrastructure as Code

- Terraform basics
- VPC, subnets, security groups
- State management

### ✅ Milestone 6: Container Orchestration

- ECS Fargate
- Task definitions
- Service discovery

### ✅ Milestone 7: Load Balancing

- Application Load Balancer
- Target groups
- Health checks

### ✅ Milestone 8: Secrets Management

- AWS Secrets Manager
- Runtime secret injection
- Key rotation

### ✅ Milestone 9: CD Pipeline

- Automated deployments
- Blue/green strategy
- Rollback procedures

### ✅ Milestone 10: Observability

- CloudWatch Logs
- Metrics & dashboards
- Alerts

## 🛠️ Tech Stack

**Application:**

- Backend: Node.js + Express + TypeScript
- Frontend: React + Vite + TypeScript

**DevOps:**

- Containers: Docker
- Orchestration: AWS ECS Fargate
- IaC: Terraform
- CI/CD: GitHub Actions
- Cloud: AWS (VPC, ALB, ECR, ECS, Secrets Manager)
- Monitoring: CloudWatch

## 📁 Project Structure

```
devops-learning-project/
├── README.md                    # This file
├── LEARNING.md                  # Detailed explanations & theory
├── ROADMAP.md                   # 7-phase senior DevOps roadmap
├── COMPLETE_LEARNING_PLAN.md    # A-Z hands-on learning tasks
├── .gitignore                   # Git ignore rules
│
├── backend/                     # Node.js Express API
│   ├── src/
│   │   └── server.ts           # Main API server
│   ├── tests/
│   ├── Dockerfile              # Multi-stage build
│   ├── .dockerignore
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/                    # React Vite app
│   ├── src/
│   ├── public/
│   ├── Dockerfile              # Multi-stage build
│   ├── nginx.conf              # Production nginx config
│   ├── package.json
│   └── tsconfig.json
│
├── docker-compose.yml           # Local development stack
├── docker-compose.monitoring.yml # Prometheus + Grafana stack
│
├── nginx/                       # Reverse proxy config
│   └── nginx.conf
│
├── .github/workflows/           # CI/CD Pipelines
│   ├── ci.yml                  # Build, Test, Scan
│   └── cd.yml                  # Deploy to AWS ECS
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Main configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── modules/
│   │   ├── vpc/main.tf         # VPC, Subnets, NAT
│   │   ├── ecr/main.tf         # Container registry
│   │   ├── ecs/main.tf         # ECS Fargate cluster
│   │   └── alb/main.tf         # Load balancer
│   └── environments/
│       ├── dev/terraform.tfvars.example
│       └── prod/terraform.tfvars.example
│
├── kubernetes/                  # K8s manifests
│   ├── base/
│   │   ├── backend.yaml        # Deployment, Service, HPA
│   │   ├── configmap.yaml      # ConfigMaps & Secrets
│   │   ├── ingress.yaml        # Ingress & NetworkPolicy
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       └── prod/
│
├── monitoring/                  # Observability stack
│   ├── prometheus/
│   │   ├── prometheus.yml      # Scrape configs
│   │   └── alertmanager.yml    # Alert routing
│   └── grafana/
│
└── scripts/                     # Helper scripts
    ├── setup-aws.sh            # AWS bootstrap (S3, DynamoDB, OIDC)
    └── init-db.sql             # Database initialization
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop
- Node.js v22+
- Terraform v1.5+
- AWS CLI v2
- AWS Account
- GitHub Account

### 1. Local Development

```bash
# Install dependencies
cd backend && npm install
cd ../frontend && npm install

# Start with Docker Compose
docker-compose up
```

Backend: http://localhost:3000
Frontend: http://localhost:5173

### 2. Deploy to AWS

```bash
# Configure AWS credentials (NEVER use hardcoded keys!)
aws configure

# Initialize Terraform
cd terraform/environments/dev
terraform init

# Plan infrastructure
terraform plan

# Apply infrastructure
terraform apply

# Deploy application (via GitHub Actions)
git push origin main
```

## 🔐 Security Checklist

- [ ] Never commit secrets to git
- [ ] Use AWS IAM roles (not static keys)
- [ ] Enable MFA on AWS root account
- [ ] Rotate secrets regularly
- [ ] Use least-privilege IAM policies
- [ ] Scan Docker images for vulnerabilities
- [ ] Enable CloudTrail for audit logs
- [ ] Use HTTPS/TLS everywhere

## 📖 Learning Resources

Each milestone has detailed explanations in `LEARNING.md`:

- Why this approach?
- Common pitfalls
- Best practices
- Troubleshooting tips

## 🤝 Next Steps After Completion

1. Add Kubernetes (EKS) version
2. Implement GitOps with ArgoCD
3. Add Prometheus + Grafana
4. Multi-region deployment
5. Chaos engineering with AWS Fault Injection Simulator

## 📝 License

MIT - For learning purposes
