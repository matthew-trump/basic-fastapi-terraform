# FastAPI Healthcheck on ECS Fargate (ECR + Terraform)

A minimal FastAPI application with a single health endpoint, packaged as a Docker image (linux/amd64), pushed to AWS ECR, and deployed to a public-facing ECS service using Terraform in **us-west-2**.

This repo is intentionally small and “Codex-friendly”: build locally, run locally, then deploy the same container to AWS.

---

## What this project does

- Runs a FastAPI app from `app/main.py`
- Exposes `GET /health` for status checks
- Runs locally via `uvicorn` on **port 8011**
- Builds a Docker image compatible with **linux/amd64**
- Pushes the image to **AWS ECR**
- Deploys an **ECS Cluster + Service + Task Definition** reachable from the public internet
- Configures ingress to allow inbound traffic on **8011**
- Adds an ECS container health check that calls `GET /health`
- Uses Terraform for infrastructure
- Includes a helper script to render `task-def.json` from a template using env vars

---

## Repository layout

├── app/
│ └── main.py
├── requirements.txt
├── Dockerfile
├── terraform/
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── ...
└── scripts/
├── task-def.template.json
└── render-task-def.sh

---

## FastAPI app

### Endpoint
- `GET /health` → returns `{ "status": "ok" }`

### Local run (no Docker)

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

uvicorn app.main:app --host 0.0.0.0 --port 8011 --reload

Test:

```curl -i http://127.0.0.1:8011/health```

## Docker
### Dockerfile expectations

The container listens on 8011

The image should be built for linux/amd64

## Build (force linux/amd64)
```docker buildx build --platform linux/amd64 -t fastapi-health-ecs:latest .```

## Run locally
```docker run --rm -p 8011:8011 fastapi-health-ecs:latest```


Test:

```curl -i http://127.0.0.1:8011/health```

## AWS + ECR
### Region

This project targets:

AWS Region: us-west-2

Make sure your AWS CLI is configured:

```aws configure```
```aws sts get-caller-identity```

### Create / reference ECR repo

Terraform will typically create the ECR repository (recommended). If you create it manually:

```aws ecr create-repository --region us-west-2 --repository-name fastapi-health-ecs```

### Login to ECR
```aws ecr get-login-password --region us-west-2 \
  | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com```

### Tag + push
```export ACCOUNT_ID="<your-account-id>"
export REPO_NAME="fastapi-health-ecs"
export IMAGE_TAG="latest"
export ECR_URI="${ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

docker tag fastapi-health-ecs:latest "${ECR_URI}"
docker push "${ECR_URI}"
```
## Notes for Codex development

Suggested “Codex loop”:

Implement minimal app/main.py and requirements.txt

Confirm uvicorn works locally on 8011

Add Dockerfile and confirm container runs locally

Add Terraform skeleton (ECR + ECS + networking)

Push image to ECR

terraform apply

Verify:

service is running

endpoint is reachable

ECS health check is passing

## License

MIT (or choose your preferred license).