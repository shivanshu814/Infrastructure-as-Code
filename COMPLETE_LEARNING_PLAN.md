# 🚀 Complete DevOps A-Z Learning Plan

Yeh plan aapke ROADMAP.md ke 7 sections ko hands-on tasks mein convert karta hai. Har section mein **Theory + Practical + Mini-Project** hai.

---

## 📅 Total Duration: 20-30 Weeks (5-7 Months)

| Phase | Topic                      | Duration  | Status |
| ----- | -------------------------- | --------- | ------ |
| 1     | Cloud (AWS)                | 4-6 weeks | ⬜     |
| 2     | Containers & Orchestration | 4-6 weeks | ⬜     |
| 3     | CI/CD Pipelines            | 3-4 weeks | ⬜     |
| 4     | Infrastructure as Code     | 4-6 weeks | ⬜     |
| 5     | Monitoring & Observability | 3-4 weeks | ⬜     |
| 6     | Security & Compliance      | 2-3 weeks | ⬜     |
| 7     | Senior DevOps/SRE Skills   | 4-8 weeks | ⬜     |

---

# 🏁 PHASE 1: Cloud (AWS) - 4 to 6 Weeks

## Week 1-2: AWS Core Services

### Day 1-2: EC2 & AMI

- [x] AWS Free Tier account banao ✅
- [x] EC2 instance launch karo (t2.micro) ✅
- [x] SSH key pair create karo ✅ (macbook pro local.pem)
- [x] Security group configure karo (port 22, 80, 443) ✅ (0.0.0.0/0 - learning only!)
- [x] Custom AMI banao running instance se ✅

**Mini Task**: Backend app ko EC2 pe deploy karo manually

```bash
# SSH to EC2
ssh -i ~/.ssh/devops-key.pem ec2-user@<public-ip>

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Clone your repo
git clone <your-repo>
cd devops-learning-project/backend
npm install
npm start
```

### Day 3-4: VPC Deep Dive

- [ ] Custom VPC create karo (10.0.0.0/16)
- [ ] Public subnet banao (10.0.1.0/24)
- [ ] Private subnet banao (10.0.2.0/24)
- [ ] Internet Gateway attach karo
- [ ] NAT Gateway for private subnet
- [ ] Route tables configure karo
- [ ] Network ACLs understand karo

**Architecture**:

```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24)
│   ├── Internet Gateway ← Route Table
│   └── NAT Gateway
├── Private Subnet (10.0.2.0/24)
│   └── Route → NAT Gateway
└── Private Subnet (10.0.3.0/24)
    └── For database/backend
```

### Day 5-6: Load Balancing & Auto Scaling

- [ ] Application Load Balancer create karo
- [ ] Target Group banao
- [ ] Health check configure karo
- [ ] Launch Template banao
- [ ] Auto Scaling Group (min:1, max:3, desired:2)
- [ ] Scaling policies (CPU based)

### Day 7-8: S3 & CloudFront

- [ ] S3 bucket create karo (versioning enabled)
- [ ] Static website hosting enable karo
- [ ] Bucket policy likhho (public read)
- [ ] CloudFront distribution create karo
- [ ] Origin Access Control setup
- [ ] Custom domain add karo (Route 53)

### Day 9-10: IAM Deep Dive

- [ ] IAM users create karo for team
- [ ] IAM groups banao (developers, admins)
- [ ] Custom IAM policies likhho
- [ ] IAM roles create karo for EC2
- [ ] Service-linked roles understand karo
- [ ] STS assume role practice

**Important Policy**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

## Week 3-4: AWS Advanced Services

### Day 11-12: CloudWatch Mastery

- [ ] Log groups create karo
- [ ] Metric filters banao (error count)
- [ ] Custom metrics push karo
- [ ] CloudWatch alarms set karo
- [ ] Dashboard banao
- [ ] Log Insights queries likhho

**Query Example**:

```
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 50
```

### Day 13-14: RDS & DynamoDB

- [ ] RDS PostgreSQL launch karo
- [ ] Multi-AZ enable karo
- [ ] Read replica banao
- [ ] Automated backups configure
- [ ] DynamoDB table create karo
- [ ] Capacity mode understand (on-demand vs provisioned)

### Day 15-16: ECR for Container Images

- [ ] Private ECR repository create karo
- [ ] IAM permissions set karo
- [ ] Docker image push karo
- [ ] Image scanning enable karo
- [ ] Lifecycle policies set karo

```bash
# ECR login
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.ap-south-1.amazonaws.com

# Build & Push
docker build -t backend:v1 ./backend
docker tag backend:v1 <account>.dkr.ecr.ap-south-1.amazonaws.com/backend:v1
docker push <account>.dkr.ecr.ap-south-1.amazonaws.com/backend:v1
```

## Week 5-6: Senior AWS Architecture

### Day 17-20: Multi-AZ & Multi-Region

- [ ] Multi-AZ VPC design karo
- [ ] Cross-AZ load balancing
- [ ] Route 53 failover routing
- [ ] Multi-region replication (S3)
- [ ] Global Accelerator explore karo

### Day 21-24: VPC Peering & Transit Gateway

- [ ] 2 VPCs create karo
- [ ] VPC Peering setup karo
- [ ] Transit Gateway for hub-spoke
- [ ] Bastion Host in public subnet
- [ ] Session Manager (no SSH keys needed!)

### Day 25-28: Cost Optimization

- [ ] AWS Cost Explorer analyse
- [ ] Budgets & alerts set karo
- [ ] Reserved Instances understand
- [ ] Spot Instances try karo
- [ ] Resource tagging strategy
- [ ] Trusted Advisor review

---

# 🐳 PHASE 2: Containers & Orchestration - 4 to 6 Weeks

## Week 7-8: Docker Mastery

### Day 1-3: Dockerfile Best Practices

- [ ] Multi-stage builds practice
- [ ] Build cache optimization
- [ ] Small base images (alpine)
- [ ] Non-root user in container
- [ ] .dockerignore complete

**Optimized Dockerfile** (./backend/Dockerfile):

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:20-alpine
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Day 4-5: Docker Volumes & Networks

- [ ] Named volumes create karo
- [ ] Bind mounts for development
- [ ] Bridge, Host, None networks
- [ ] Custom network create karo
- [ ] Container DNS understand karo

### Day 6-7: Docker Compose Advanced

- [ ] Multi-service compose file
- [ ] Environment files (.env)
- [ ] Healthchecks in compose
- [ ] Dependencies (depends_on)
- [ ] Override files (compose.override.yml)

## Week 9-10: Kubernetes Core

### Day 8-10: Kubernetes Basics

- [ ] Minikube/Kind install karo
- [ ] kubectl commands learn
- [ ] Pods create karo (imperative & declarative)
- [ ] Labels & selectors
- [ ] Namespaces understand karo

**First Pod**:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod
  labels:
    app: backend
spec:
  containers:
    - name: backend
      image: backend:v1
      ports:
        - containerPort: 3000
```

### Day 11-13: Deployments & Services

- [ ] Deployment create karo
- [ ] ReplicaSets understand karo
- [ ] Rolling updates
- [ ] Rollback karo
- [ ] ClusterIP, NodePort, LoadBalancer services
- [ ] Ingress controller install (nginx)

### Day 14-16: ConfigMaps & Secrets

- [ ] ConfigMap from file
- [ ] ConfigMap from literal
- [ ] Mount as volume
- [ ] Environment variables from ConfigMap
- [ ] Secrets create (generic, docker-registry)
- [ ] NEVER commit secrets!

## Week 11-12: Kubernetes Advanced

### Day 17-19: StatefulSets & Storage

- [ ] PersistentVolume create karo
- [ ] PersistentVolumeClaim
- [ ] StorageClasses
- [ ] StatefulSet for database
- [ ] Headless service

### Day 20-22: HPA & Scaling

- [ ] Metrics server install karo
- [ ] HPA create karo (CPU based)
- [ ] Custom metrics with HPA
- [ ] Cluster Autoscaler (EKS)

### Day 23-25: RBAC & Network Policies

- [ ] ServiceAccount create karo
- [ ] Role & RoleBinding
- [ ] ClusterRole & ClusterRoleBinding
- [ ] NetworkPolicy (ingress/egress)

### Day 26-28: Helm & Operators

- [ ] Helm install karo
- [ ] Helm chart structure samjho
- [ ] Values.yaml customize karo
- [ ] Create your own chart
- [ ] Explore operators (cert-manager, prometheus-operator)

---

# 🔄 PHASE 3: CI/CD Pipelines - 3 to 4 Weeks

## Week 13-14: GitHub Actions

### Day 1-3: Basic Workflows

- [ ] First workflow create karo
- [ ] Triggers (push, PR, schedule)
- [ ] Jobs & steps
- [ ] Actions marketplace explore
- [ ] Environment variables & secrets

**Create file**: `.github/workflows/ci.yml`

```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci
        working-directory: ./backend

      - name: Run tests
        run: npm test
        working-directory: ./backend

      - name: Build
        run: npm run build
        working-directory: ./backend

  build-docker:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t backend:${{ github.sha }} ./backend
```

### Day 4-6: Docker & ECR Integration

- [ ] AWS credentials (OIDC preferred)
- [ ] Build & push to ECR
- [ ] Image tagging strategy
- [ ] Caching Docker layers

### Day 7-10: Deployment Pipelines

- [ ] CD workflow create karo
- [ ] Environment protection rules
- [ ] Manual approval for prod
- [ ] Rollback workflow

## Week 15-16: Advanced CI/CD

### Day 11-13: Security Scanning

- [ ] Trivy for container scanning
- [ ] Dependabot enable karo
- [ ] CodeQL for SAST
- [ ] Branch protection rules

### Day 14-17: Deployment Strategies

- [ ] Blue-Green deployment
- [ ] Canary deployment (Argo Rollouts)
- [ ] Feature flags (basic)
- [ ] Automated rollbacks

### Day 18-21: Reusable Workflows

- [ ] Composite actions
- [ ] Reusable workflows
- [ ] Matrix builds
- [ ] Monorepo CI strategies

---

# 🏗️ PHASE 4: Infrastructure as Code - 4 to 6 Weeks

## Week 17-18: Terraform Fundamentals

### Day 1-3: Terraform Basics

- [ ] Terraform install karo
- [ ] First provider (AWS)
- [ ] Resource create karo (S3)
- [ ] Variables & outputs
- [ ] terraform.tfvars

**File Structure**:

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── terraform.tfvars
```

### Day 4-6: Terraform State

- [ ] Local state samjho
- [ ] Remote state (S3)
- [ ] State locking (DynamoDB)
- [ ] State commands (mv, rm, import)
- [ ] NEVER commit tfstate!

### Day 7-10: Modules

- [ ] VPC module create karo
- [ ] ECR module create karo
- [ ] ECS module create karo
- [ ] Module registry use karo
- [ ] Module versioning

## Week 19-20: Terraform Advanced

### Day 11-14: Multi-Environment

- [ ] Workspaces use karo
- [ ] Per-environment tfvars
- [ ] Terragrunt (optional)
- [ ] DRY principles

**Environment Structure**:

```
terraform/
├── modules/
│   ├── vpc/
│   ├── ecs/
│   └── rds/
└── environments/
    ├── dev/
    │   ├── main.tf
    │   └── terraform.tfvars
    └── prod/
        ├── main.tf
        └── terraform.tfvars
```

### Day 15-18: CI/CD with Terraform

- [ ] Terraform in GitHub Actions
- [ ] terraform plan as PR comment
- [ ] terraform apply on merge
- [ ] State file locking
- [ ] Drift detection

### Day 19-21: Ansible Basics

- [ ] Ansible install karo
- [ ] Inventory file banao
- [ ] First playbook
- [ ] Roles structure
- [ ] Jinja2 templates

**Playbook Example**:

```yaml
---
- name: Configure webserver
  hosts: webservers
  become: yes

  tasks:
    - name: Install Node.js
      yum:
        name: nodejs
        state: present

    - name: Copy application
      copy:
        src: ./app
        dest: /opt/app

    - name: Start application
      systemd:
        name: myapp
        state: started
        enabled: yes
```

---

# 📊 PHASE 5: Monitoring & Observability - 3 to 4 Weeks

## Week 21-22: Monitoring Stack

### Day 1-4: Prometheus

- [ ] Prometheus install karo (Docker)
- [ ] prometheus.yml configuration
- [ ] PromQL basics
- [ ] Alertmanager setup
- [ ] Recording rules

### Day 5-8: Grafana

- [ ] Grafana install karo
- [ ] Prometheus data source add karo
- [ ] Dashboard create karo
- [ ] Panels customize karo
- [ ] Dashboard import from community

### Day 9-12: EFK Stack

- [ ] Elasticsearch deploy karo
- [ ] FluentBit/Fluentd for log collection
- [ ] Kibana for visualization
- [ ] Log parsing & indexing
- [ ] Index lifecycle policies

## Week 23-24: Advanced Observability

### Day 13-16: Distributed Tracing

- [ ] Jaeger install karo
- [ ] OpenTelemetry SDK add karo
- [ ] Trace propagation samjho
- [ ] Span attributes add karo
- [ ] Trace sampling

### Day 17-21: SLO/SLI Based Alerting

- [ ] SLIs define karo (latency, error rate)
- [ ] SLOs set karo (99.9% availability)
- [ ] Error budget calculate karo
- [ ] Alert on burn rate
- [ ] Runbooks likhho

---

# 🔐 PHASE 6: Security & Compliance - 2 to 3 Weeks

## Week 25: Security Basics

### Day 1-3: IAM & Secrets

- [ ] Least privilege review
- [ ] HashiCorp Vault setup
- [ ] Vault secrets engine
- [ ] Dynamic secrets
- [ ] Secret rotation

### Day 4-7: Container Security

- [ ] Docker image scanning (Trivy)
- [ ] Runtime security
- [ ] Kubernetes RBAC audit
- [ ] NetworkPolicies implement karo
- [ ] Pod Security Standards

## Week 26-27: Advanced Security

### Day 8-10: Network Security

- [ ] mTLS understand karo
- [ ] Service Mesh (Istio basics)
- [ ] Zero Trust networking
- [ ] AWS Security Groups audit

### Day 11-14: Compliance & Audit

- [ ] CloudTrail enable karo
- [ ] AWS Config rules
- [ ] GuardDuty enable karo
- [ ] Policy as Code (OPA/Kyverno)
- [ ] Compliance dashboards

---

# 🏆 PHASE 7: Senior DevOps / SRE Skills - 4 to 8 Weeks

## Week 28-30: Architecture & Reliability

### Day 1-7: HA Architecture

- [ ] Multi-AZ design karo
- [ ] Active-active setup
- [ ] Database failover
- [ ] Cache layer (Redis)
- [ ] Message queue (SQS/Kafka)

### Day 8-14: SRE Practices

- [ ] Incident management process
- [ ] On-call rotations
- [ ] Post-mortem template
- [ ] Error budget tracking
- [ ] Chaos engineering (AWS FIS)

## Week 31-35: Automation & Networking

### Day 15-21: Complete Automation

- [ ] Self-healing infrastructure
- [ ] Auto-scaling fine-tuning
- [ ] GitOps (ArgoCD)
- [ ] Policy automation

### Day 22-28: Advanced Networking

- [ ] Load balancer algorithms
- [ ] Nginx/HAProxy configuration
- [ ] API Gateway patterns
- [ ] CDN optimization
- [ ] DNS strategies

---

# 📝 HANDS-ON PROJECTS

## Project 1: Complete This App Deployment

Deploy backend + frontend using:

- [x] Docker (local)
- [ ] Docker Compose (local)
- [ ] ECR + ECS Fargate (AWS)
- [ ] GitHub Actions CI/CD
- [ ] Terraform for infrastructure
- [ ] CloudWatch monitoring

## Project 2: Kubernetes Deployment

- [ ] Setup Minikube/Kind
- [ ] Create K8s manifests
- [ ] Helm chart for app
- [ ] Ingress with TLS
- [ ] HPA + Prometheus

## Project 3: Multi-Environment Pipeline

- [ ] Dev, Staging, Prod environments
- [ ] Terraform for each env
- [ ] GitHub Actions with approvals
- [ ] Blue-Green deployments
- [ ] Automated rollbacks

## Project 4: Full Observability Stack

- [ ] Prometheus + Grafana
- [ ] EFK for logging
- [ ] Jaeger for tracing
- [ ] SLO dashboards
- [ ] PagerDuty integration

---

# 🎯 DAILY STUDY PLAN

## Weekday Routine (2-3 hours)

```
7:00 - 7:30 AM  : Theory (read docs/watch video)
7:30 - 8:30 AM  : Hands-on practice
8:30 - 9:00 AM  : Document what you learned
Evening 30 min  : Review & plan next day
```

## Weekend Routine (4-5 hours)

```
Morning  : Mini project work
Afternoon: Practice & troubleshooting
Evening  : Write blog/notes
```

---

# 📚 RESOURCES

## Free Courses

- [ ] AWS Skill Builder (free tier)
- [ ] KodeKloud (paid but worth it)
- [ ] Kubernetes official tutorials
- [ ] Terraform HashiCorp Learn

## YouTube Channels

- TechWorld with Nana
- DevOps Directive
- Cloud With Raj
- Abhishek Veeramalla (Hindi)

## Books

- "The Phoenix Project"
- "The DevOps Handbook"
- "Site Reliability Engineering" (Google SRE Book)

## Certifications Path

1. AWS Certified Cloud Practitioner
2. AWS Certified Solutions Architect - Associate
3. Terraform Associate
4. Certified Kubernetes Administrator (CKA)

---

# ✅ PROGRESS TRACKER

Mark ✅ as you complete each phase:

- [ ] Phase 1: AWS Cloud
- [ ] Phase 2: Containers & K8s
- [ ] Phase 3: CI/CD
- [ ] Phase 4: Terraform & Ansible
- [ ] Phase 5: Monitoring
- [ ] Phase 6: Security
- [ ] Phase 7: Senior Skills

---

**Remember**: Consistency > Intensity. Daily 2-3 hours > Weekend marathons!

Har cheez try karo, break karo, fix karo. Mistakes se hi seekhoge! 💪🚀
