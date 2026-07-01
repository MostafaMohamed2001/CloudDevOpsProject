# CloudDevOpsProject

End-to-end DevOps pipeline that provisions AWS infrastructure, configures servers, containerizes and deploys an application to Kubernetes, and automates the full CI/CD flow with Jenkins and ArgoCD.

**Source application:** [FinalProject](https://github.com/IbrahimAdel15/FinalProject.git)

---

## Architecture Overview

```
                ┌──────────────────────────────────────────────┐
                │                   AWS VPC                     │
                │                                                │
                │   ┌───────────────┐      ┌─────────────────┐  │
                │   │ Public Subnet │      │ Private Subnet  │  │
                │   │               │      │  (AZ-1)         │  │
                │   │  Jenkins EC2  │      │  EKS Worker 1   │  │
                │   │  (IGW/NAT)    │      │                 │  │
                │   └───────────────┘      └─────────────────┘  │
                │                          ┌─────────────────┐  │
                │                          │ Private Subnet  │  │
                │                          │  (AZ-2)         │  │
                │                          │  EKS Worker 2   │  │
                │                          └─────────────────┘  │
                │                                                │
                │              ECR (container images)            │
                └──────────────────────────────────────────────┘

Jenkins CI  →  Build → Scan (Trivy) → Push to ECR → Update Manifests → Push
                                                              │
                                                              ▼
                                                    ArgoCD (GitOps CD)
                                                              │
                                                              ▼
                                          EKS: iVolve namespace
                                          Deployment (2 replicas, separate nodes)
                                          Service + Ingress
```

**Flow:** Jenkins builds and scans the Docker image, pushes it to ECR, then updates the Kubernetes manifests in Git. ArgoCD watches the Git repo and automatically syncs the new manifests to the EKS cluster.

---

## Repository Structure

```
CloudDevOpsProject/
├── Dockerfile                  # Application container image
├── terraform/
│   ├── network/                # VPC, public/private subnets, IGW, NAT, NACLs
│   ├── server/                 # Jenkins EC2 + Security Groups
│   ├── eks/                    # EKS cluster, 2 worker nodes across AZs
│   ├── ecr/                    # ECR repository
│   └── backend.tf              # S3 remote state backend
├── ansible/
│   ├── inventory/              # Dynamic inventory (AWS EC2 plugin)
│   ├── roles/
│   │   ├── java/                # Install Java
│   │   ├── jenkins/             # Install Jenkins
│   │   └── docker_trivy/        # Install Docker & Trivy
│   └── playbook.yml
├── k8s/
│   ├── namespace.yaml           # iVolve namespace
│   ├── deployment.yaml          # 2 replicas, anti-affinity across nodes
│   ├── service.yaml
│   └── ingress.yaml
├── jenkins/
│   ├── Jenkinsfile              # Pipeline definition
│   └── vars/                    # Shared library (pipeline steps)
├── argocd/
│   └── application.yaml         # ArgoCD Application manifest
└── README.md
```

---

## Tech Stack

| Layer | Tools |
|---|---|
| Source Control | GitHub |
| Containerization | Docker |
| Infrastructure as Code | Terraform (S3 backend) |
| Configuration Management | Ansible (roles + dynamic inventory) |
| Orchestration | Kubernetes (EKS) |
| CI | Jenkins (shared library) |
| Image Scanning | Trivy |
| CD | ArgoCD (GitOps) |
| Cloud Provider | AWS (VPC, EC2, EKS, ECR) |

---

## Setup Instructions

### Prerequisites
- AWS account with configured credentials (`aws configure`)
- Terraform >= 1.5
- Ansible >= 2.14
- `kubectl` and `eksctl`
- Jenkins (or provisioned via the `server` Terraform module)
- ArgoCD CLI

### 1. Clone the repository
```bash
git clone https://github.com/<your-username>/CloudDevOpsProject.git
cd CloudDevOpsProject
```

### 2. Provision infrastructure with Terraform
```bash
cd terraform
terraform init      # initializes S3 backend
terraform plan
terraform apply
```
This creates the VPC/subnets, the Jenkins EC2 instance, the EKS cluster (2 worker nodes across separate AZs/subnets), and the ECR repository.

### 3. Configure the Jenkins server with Ansible
```bash
cd ../ansible
ansible-playbook -i inventory/aws_ec2.yml playbook.yml
```
Installs Java, Jenkins, Docker, and Trivy on the provisioned EC2 instance via roles.

### 4. Deploy Kubernetes resources
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

### 5. Set up the Jenkins pipeline
- Open Jenkins → New Item → Pipeline.
- Point it to this repository's `jenkins/Jenkinsfile`.
- Ensure the shared library in `jenkins/vars` is registered under **Manage Jenkins → Global Pipeline Libraries**.
- Pipeline stages: Build Image → Scan Image (Trivy) → Push Image → Delete Image Locally → Update Manifests → Push Manifests.

### 6. Configure ArgoCD
```bash
kubectl apply -f argocd/application.yaml
argocd app sync CloudDevOpsProject
```
ArgoCD will continuously sync the `iVolve` namespace deployment with the manifests in this repository.

---

## Result

Once complete, every push to the application source triggers Jenkins to build, scan, and push a new image, update the Kubernetes manifests, and hand off to ArgoCD for automated, GitOps-driven deployment to the EKS cluster — with the app running as 2 replicas spread across separate nodes and availability zones, exposed via a Kubernetes Service and Ingress.

---

## Author

**Mustafa Mohamed** — DevOps & Cloud Engineer
[GitHub](https://github.com/MostafaMohamed2001) • [LinkedIn](https://linkedin.com/in/mustafa-mohamed-330605257)
