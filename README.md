# 🚀 Automated Cloud Deployment Pipeline

A production-ready CI/CD pipeline deploying a **Flask app** to **AWS EC2** using:

> **Flask** → **Docker** → **GitHub Actions** → **EC2** → **Nginx** → **SSL (Let's Encrypt)**  
> Provisioned with **Terraform** · Configured with **Ansible**

---

## 📁 Project Structure

```
cloud-deploy-pipeline/
├── app/
│   ├── app.py                  # Flask Hello World application
│   └── requirements.txt        # Python dependencies
├── terraform/
│   ├── main.tf                 # EC2 + Security Group + Elastic IP
│   ├── variables.tf            # Input variables
│   └── outputs.tf              # Outputs (IP, SSH command, etc.)
├── ansible/
│   ├── playbook.yml            # Install Docker, Nginx, run container
│   ├── inventory.ini           # Target EC2 server
│   └── templates/
│       └── nginx.conf.j2       # Nginx reverse proxy template
├── nginx/
│   └── nginx.conf              # Manual Nginx config (reference)
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
├── .gitlab-ci.yml              # GitLab CI/CD pipeline (alternative)
├── Dockerfile                  # Multi-stage Docker build
├── .gitignore
└── README.md
```

---

## ⚡ Quick Start

### Prerequisites
- AWS account with CLI configured (`aws configure`)
- Terraform ≥ 1.5
- Ansible ≥ 2.14
- An AWS Key Pair created in your target region
- A GitHub account (for GHCR image registry)

---

## Step 1 — Provision EC2 with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Preview what will be created
terraform plan -var="key_pair_name=your-aws-key"

# Create the infrastructure
terraform apply -var="key_pair_name=your-aws-key"

# Note the outputs
terraform output public_ip     # → Add to GitHub Secrets as EC2_HOST
terraform output ssh_command   # → Quick SSH access command
```

**Resources created:**
- EC2 instance (t2.micro, free-tier eligible)
- Security Group (ports 22, 80, 443)
- Elastic IP (stable public address)

> **💡 For Mumbai region**, change `ami_id` in `variables.tf` to `ami-0f58b397bc5c1f2e8`

---

## Step 2 — Configure Server with Ansible

Edit `ansible/inventory.ini` with your EC2 IP:
```ini
flask-prod  ansible_host=YOUR_EC2_IP
```

Edit `ansible/playbook.yml`:
```yaml
docker_image: "ghcr.io/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:latest"
domain_name: "yourdomain.com"   # or use the EC2 IP
```

Run the playbook:
```bash
cd ansible

# Install required Ansible collection
ansible-galaxy collection install community.docker

# Run the full setup playbook
ansible-playbook -i inventory.ini playbook.yml
```

**This installs:**
- Docker CE + Docker Compose
- Nginx
- Certbot (Let's Encrypt SSL client)
- Pulls & runs your Docker container
- Configures Nginx as reverse proxy

---

## Step 3 — Set GitHub Secrets

In your GitHub repo → **Settings → Secrets and variables → Actions**:

| Secret Name   | Value                                |
|---------------|--------------------------------------|
| `EC2_HOST`    | Your EC2 Elastic IP                  |
| `EC2_SSH_KEY` | Contents of your `.pem` private key  |

---

## Step 4 — Push and Deploy

```bash
git add .
git commit -m "feat: initial deployment pipeline"
git push origin main
```

GitHub Actions will automatically:
1. 🐳 Build the Docker image
2. 📦 Push it to GitHub Container Registry (GHCR)
3. 🚀 SSH into EC2 and pull + restart the container
4. 🩺 Run a health check against `/health`

---

## Step 5 — SSL Certificate (Optional but Recommended)

Once DNS is pointed to your EC2 IP:

```bash
# Run Ansible with SSL enabled
ansible-playbook -i inventory.ini playbook.yml \
  -e "use_ssl=true domain_name=yourdomain.com"
```

Or SSH in manually:
```bash
sudo certbot --nginx -d yourdomain.com --redirect
```

Certbot auto-renews every 90 days. Test renewal:
```bash
sudo certbot renew --dry-run
```

---

## 🔁 CI/CD Pipeline Flow

```
git push main
    │
    ▼
GitHub Actions
    │
    ├─ Build Docker image
    ├─ Push to ghcr.io/username/repo:latest
    │
    ├─ SSH into EC2
    │   ├─ docker pull image
    │   ├─ docker stop old container
    │   └─ docker run new container
    │
    └─ Health check → GET /health → HTTP 200 ✅

EC2
└─ Nginx (port 80/443)
   └─ Reverse proxy → Flask/Gunicorn (port 5000)
```

---

## 🧪 Test Locally

```bash
# Build and run with Docker
docker build -t flask-app .
docker run -p 5000:5000 flask-app

# Visit: http://localhost:5000
# Health: http://localhost:5000/health
```

---

## 🔐 Security Notes

- Restrict SSH to your IP in `variables.tf`: `allowed_ssh_cidr = "YOUR.IP.HERE/32"`
- Never commit `.pem` files (protected by `.gitignore`)
- Use HTTPS (Step 5) before going to production
- GHCR images are private by default for private repos

---

## 🛠 Useful Commands

```bash
# SSH into server
ssh -i ~/.ssh/your-key.pem ubuntu@$(terraform output -raw public_ip)

# View running container
docker ps

# Stream container logs
docker logs -f flask-app

# Restart container
docker restart flask-app

# Reload Nginx
sudo systemctl reload nginx
```

---

## 📚 Tech Stack

| Tool       | Role                            |
|------------|---------------------------------|
| Flask      | Python web application          |
| Gunicorn   | Production WSGI server          |
| Docker     | Containerization                |
| Terraform  | Infrastructure as Code (EC2)    |
| Ansible    | Configuration management        |
| Nginx      | Reverse proxy + SSL termination |
| Certbot    | Free SSL via Let's Encrypt      |
| GitHub Actions | CI/CD pipeline             |
| GHCR       | Docker image registry           |
| AWS EC2    | Cloud compute                   |
