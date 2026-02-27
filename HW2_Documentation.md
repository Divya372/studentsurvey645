# SWE645 - Assignment 2: Docker, Kubernetes & CI/CD Pipeline

**Name:** Divya Soni  
**Course:** SWE645  
**Assignment:** Homework 2

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Files Included](#files-included)
3. [Prerequisites](#prerequisites)
4. [Part 1: Docker Setup](#part-1-docker-setup)
5. [Part 2: Kubernetes Deployment with Rancher](#part-2-kubernetes-deployment-with-rancher)
6. [Part 3: Jenkins CI/CD Pipeline](#part-3-jenkins-cicd-pipeline)
7. [Live URLs](#live-urls)
8. [Troubleshooting](#troubleshooting)

---

## Project Overview

This project containerizes the Student Survey web application from HW1 using Docker, deploys it to a Kubernetes cluster using Rancher on AWS, and establishes a CI/CD pipeline using Jenkins for automated builds and deployments.

### Architecture

```
GitHub Repository → Jenkins (CI/CD) → Docker Hub → Kubernetes (Rancher/AWS)
```

---

## Files Included

| File | Description |
|------|-------------|
| `index.html` | Main homepage |
| `survey.html` | Student Survey form |
| `error.html` | Error page |
| `campus.jpg` | Campus image |
| `Dockerfile` | Docker configuration file |
| `deployment.yaml` | Kubernetes Deployment manifest (3 replicas) |
| `service.yaml` | Kubernetes Service manifest (LoadBalancer) |
| `Jenkinsfile` | CI/CD pipeline configuration |
| `HW2_Documentation.md` | This documentation file |

---

## Prerequisites

Before starting, ensure you have:

- [x] AWS Account (AWS Academy)
- [x] Docker Hub account (https://hub.docker.com)
- [x] GitHub account
- [x] Docker Desktop installed on your machine
- [x] Git installed

---

## Part 1: Docker Setup

### Step 1.1: Install Docker Desktop

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Install and restart your computer
3. Verify installation:
   ```bash
   docker --version
   ```

### Step 1.2: Create Docker Hub Account

1. Go to https://hub.docker.com
2. Sign up for a free account
3. Remember your username (you'll need it later)

### Step 1.3: Build Docker Image

Open PowerShell/Terminal and navigate to your project folder:

```bash
cd C:\Users\lenovo\Desktop\ass1-645
```

Build the Docker image (replace `YOUR_DOCKERHUB_USERNAME` with your actual username):

```bash
docker build -t YOUR_DOCKERHUB_USERNAME/studentsurvey645:latest .
```

### Step 1.4: Test Docker Image Locally

```bash
docker run -d -p 8080:80 YOUR_DOCKERHUB_USERNAME/studentsurvey645:latest
```

Open browser and go to: `http://localhost:8080`

You should see your website running!

### Step 1.5: Push Image to Docker Hub

Login to Docker Hub:

```bash
docker login
```

Push the image:

```bash
docker push YOUR_DOCKERHUB_USERNAME/studentsurvey645:latest
```

### Step 1.6: Verify on Docker Hub

1. Go to https://hub.docker.com
2. Click on your profile
3. You should see your `studentsurvey645` repository

---

## Part 2: Kubernetes Deployment with Rancher

### Step 2.1: Create Rancher EC2 Instance

1. Log in to **AWS Academy** → **AWS Console**
2. Go to **EC2** → **Launch Instance**
3. Configure:
   - **Name:** `Rancher-Server`
   - **AMI:** Ubuntu Server 22.04 LTS
   - **Instance Type:** `t2.medium` (Rancher needs more resources)
   - **Key Pair:** Create new or use existing
   - **Security Group:** Allow ports:
     - SSH (22)
     - HTTP (80)
     - HTTPS (443)
     - Custom TCP (6443) - Kubernetes API
4. Click **Launch Instance**

### Step 2.2: Install Docker on Rancher Instance

SSH into your Rancher instance:

```bash
ssh -i "your-key.pem" ubuntu@YOUR-RANCHER-PUBLIC-IP
```

Install Docker:

```bash
sudo apt-get update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version
```

### Step 2.3: Install Rancher

Run Rancher container:

```bash
sudo docker run --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
```

Wait 2-3 minutes, then open browser: `https://YOUR-RANCHER-PUBLIC-IP`

Accept the security warning and follow setup:
1. Get bootstrap password: `sudo docker logs $(sudo docker ps -q) 2>&1 | grep "Bootstrap Password"`
2. Set admin password
3. Set Rancher Server URL

### Step 2.4: Create Kubernetes Cluster in Rancher

1. In Rancher UI, click **Create** (or **Add Cluster**)
2. Select **Amazon EC2**
3. Configure:
   - **Cluster Name:** `studentsurvey-cluster`
   - Enter AWS Access Key and Secret Key (from AWS IAM)
   - **Region:** `us-east-1` (or your preferred region)
4. Create Node Template:
   - Instance Type: `t2.medium`
   - Choose appropriate AMI
5. Add Node Pool:
   - **etcd:** 1 node
   - **Control Plane:** 1 node
   - **Worker:** 2-3 nodes
6. Click **Create**

Wait 10-15 minutes for cluster to provision.

### Step 2.5: Deploy Application to Kubernetes

#### Option A: Using Rancher UI

1. Click on your cluster
2. Go to **Workload** → **Deployments**
3. Click **Create**
4. Fill in:
   - **Name:** `studentsurvey-deployment`
   - **Docker Image:** `YOUR_DOCKERHUB_USERNAME/studentsurvey645:latest`
   - **Replicas:** 3
   - **Port:** 80
5. Click **Create**

#### Option B: Using kubectl

1. In Rancher, click on cluster → **Kubeconfig File**
2. Copy the content
3. Save to `~/.kube/config` on your local machine

Apply deployment:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Verify deployment:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

### Step 2.6: Access Your Application

1. Go to **Services** in Rancher
2. Find `studentsurvey-service`
3. Click on the external IP/URL
4. Your application should be running!

---

## Part 3: Jenkins CI/CD Pipeline

### Step 3.1: Create Jenkins EC2 Instance

1. Go to **EC2** → **Launch Instance**
2. Configure:
   - **Name:** `Jenkins-Server`
   - **AMI:** Ubuntu Server 22.04 LTS
   - **Instance Type:** `t2.medium`
   - **Key Pair:** Create new or use existing
   - **Security Group:** Allow ports:
     - SSH (22)
     - HTTP (8080) - Jenkins
3. Click **Launch Instance**

### Step 3.2: Install Jenkins

SSH into Jenkins instance:

```bash
ssh -i "your-key.pem" ubuntu@YOUR-JENKINS-PUBLIC-IP
```

Install Java:

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
```

Install Jenkins:

```bash
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

Install Docker:

```bash
sudo apt install -y docker.io
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Install kubectl:

```bash
sudo snap install kubectl --classic
```

### Step 3.3: Configure Jenkins

1. Open browser: `http://YOUR-JENKINS-PUBLIC-IP:8080`
2. Get initial admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Install suggested plugins
4. Create admin user

### Step 3.4: Install Required Plugins

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Install:
   - Docker Pipeline
   - GitHub Integration
   - Kubernetes CLI
   - Credentials Binding

### Step 3.5: Configure Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Add credentials:

   **Docker Hub:**
   - Kind: Username with password
   - ID: `dockerhub-credentials`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password

### Step 3.6: Configure kubectl for Jenkins

SSH into Jenkins server:

```bash
sudo su jenkins
mkdir -p ~/.kube
```

Copy kubeconfig content from Rancher and paste into:

```bash
nano ~/.kube/config
```

Verify:

```bash
kubectl get nodes
```

### Step 3.7: Create GitHub Repository

1. Go to GitHub and create new repository: `studentsurvey645`
2. Push your code:

```bash
cd C:\Users\lenovo\Desktop\ass1-645
git init
git add .
git commit -m "Initial commit - HW2"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/studentsurvey645.git
git push -u origin main
```

### Step 3.8: Create Jenkins Pipeline

1. In Jenkins, click **New Item**
2. Enter name: `studentsurvey-pipeline`
3. Select **Pipeline**
4. Configure:
   - **Build Triggers:** Poll SCM: `* * * * *` (every minute)
   - **Pipeline:**
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: Your GitHub URL
     - Branch: `*/main`
     - Script Path: `Jenkinsfile`
5. Click **Save**

### Step 3.9: Update Configuration Files

Before running the pipeline, update these files with your Docker Hub username:

**deployment.yaml:**
```yaml
image: YOUR_DOCKERHUB_USERNAME/studentsurvey645:latest
```

**Jenkinsfile:**
```groovy
DOCKER_HUB_REPO = "YOUR_DOCKERHUB_USERNAME/studentsurvey645"
```

Push changes to GitHub:

```bash
git add .
git commit -m "Updated Docker Hub username"
git push
```

### Step 3.10: Run Pipeline

1. In Jenkins, click on your pipeline
2. Click **Build Now**
3. Monitor the build progress
4. Check each stage completes successfully

---

## Live URLs

Update these URLs after deployment:

| Service | URL |
|---------|-----|
| **S3 Static Website** | `http://div-645-assignment1.s3-website.us-east-2.amazonaws.com` |
| **EC2 Instance** | `http://3.138.154.222` |
| **Kubernetes (LoadBalancer)** | `http://YOUR-K8S-LOADBALANCER-URL` |
| **Jenkins** | `http://YOUR-JENKINS-IP:8080` |
| **Rancher** | `https://YOUR-RANCHER-IP` |
| **Docker Hub** | `https://hub.docker.com/r/YOUR_USERNAME/studentsurvey645` |
| **GitHub** | `https://github.com/YOUR_USERNAME/studentsurvey645` |

---

## Verifying Requirements

### Requirement Checklist

- [x] **Containerization:** Application containerized with Docker
- [x] **Docker Hub:** Image pushed to Docker Hub with tags
- [x] **Kubernetes Deployment:** 3 replicas running
- [x] **Kubernetes Service:** LoadBalancer exposing application
- [x] **CI/CD Pipeline:** Jenkins pipeline with automated build/deploy
- [x] **GitHub:** Source code managed in repository

### Verify 3 Pods Running

```bash
kubectl get pods
```

Expected output:
```
NAME                                        READY   STATUS    RESTARTS   AGE
studentsurvey-deployment-xxxxx-xxxxx        1/1     Running   0          5m
studentsurvey-deployment-xxxxx-xxxxx        1/1     Running   0          5m
studentsurvey-deployment-xxxxx-xxxxx        1/1     Running   0          5m
```

### Test Pod Resiliency

Delete one pod:

```bash
kubectl delete pod studentsurvey-deployment-xxxxx-xxxxx
```

Check pods again - a new pod should be created automatically:

```bash
kubectl get pods
```

---

## Troubleshooting

### Docker Issues

| Problem | Solution |
|---------|----------|
| Docker build fails | Check Dockerfile syntax and file paths |
| Cannot push to Docker Hub | Run `docker login` first |
| Image not found | Verify image name and tag |

### Kubernetes Issues

| Problem | Solution |
|---------|----------|
| Pods not starting | Check `kubectl describe pod <pod-name>` |
| Service not accessible | Verify security groups allow traffic |
| kubectl not working | Check kubeconfig file |

### Jenkins Issues

| Problem | Solution |
|---------|----------|
| Build fails | Check Jenkins console output |
| Cannot connect to Docker | Add jenkins user to docker group |
| kubectl fails | Verify kubeconfig in Jenkins |

### Common Commands

```bash
# View pod logs
kubectl logs <pod-name>

# Describe deployment
kubectl describe deployment studentsurvey-deployment

# Check service status
kubectl get svc studentsurvey-service

# Restart deployment
kubectl rollout restart deployment/studentsurvey-deployment
```

---

## Cleanup (After Grading)

To avoid charges, delete resources:

1. **Rancher:** Delete cluster in Rancher UI
2. **EC2:** Terminate all instances
3. **Load Balancer:** Delete in AWS console
4. **Security Groups:** Delete custom groups

---

## References

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Rancher Documentation](https://rancher.com/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [AWS Documentation](https://docs.aws.amazon.com/)

---

**End of Documentation**
