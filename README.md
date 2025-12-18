# FastAPI Healthcheck on ECS Fargate (ECR + Terraform)

A minimal FastAPI application with a single health endpoint, packaged as a Docker image (linux/amd64), pushed to AWS ECR, and deployed to a public-facing ECS service using Terraform in **us-west-2**.

This repo is intentionally small and Codex-friendly: build locally, run locally, then deploy the same container to AWS.

---

## What this project does

- Runs a FastAPI app from `app/main.py`
- Exposes `GET /health` for status checks
- Runs locally via `uvicorn` on port **8011**
- Builds a Docker image compatible with **linux/amd64**
- Pushes the image to **AWS ECR**
- Deploys an ECS Cluster, Service, and Task Definition reachable from the public internet
- Configures ingress to allow inbound traffic on **8011**
- Adds an ECS container health check that calls `GET /health`
- Uses Terraform for infrastructure
- Includes a helper script to render `task-def.json` from a template using environment variables

---

## Repository layout

```
.
├── app/
│   └── main.py
├── requirements.txt
├── Dockerfile
├── tests/
│   └── test_health.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
└── scripts/
    ├── task-def.template.json
    └── render-task-def.sh
```

---

## FastAPI app

### Endpoint

`GET /health` → `{ "status": "ok" }`

### Local run (no Docker)

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

uvicorn app.main:app --host 0.0.0.0 --port 8011 --reload
```

Or use the `Makefile` target:

```bash
make run
```

Test:

```bash
curl -i http://127.0.0.1:8011/health
```

---

## Docker

### Build (linux/amd64)

```bash
docker buildx build --platform linux/amd64 -t fastapi-health-ecs:latest .
```

### Run locally

```bash
docker run --rm -p 8011:8011 fastapi-health-ecs:latest
```

---

## Testing

Run tests with pytest or the `Makefile` target:

```bash
python -m pytest
```

```bash
make test
```

---

## AWS + ECR

- Region: **us-west-2**

Authenticate and push the image to ECR before deploying infrastructure.

---

## ECS architecture (high level)

Terraform provisions:

- ECS Cluster
- ECS Task Definition (Fargate)
- ECS Service
- Networking and security groups
- Public ingress on port 8011 (direct or via ALB)

---

## ECS health check

Example container health check:

```json
"healthCheck": {
  "command": ["CMD-SHELL", "curl -fsS http://localhost:8011/health || exit 1"],
  "interval": 30,
  "timeout": 5,
  "retries": 3,
  "startPeriod": 10
}
```

---

## Terraform usage

```bash
cd terraform
terraform init
terraform plan -var="aws_region=us-west-2"
terraform apply -var="aws_region=us-west-2"
```

---

## Task definition rendering

Environment-driven rendering of `task-def.json`:

```bash
export AWS_REGION=us-west-2
export TASK_FAMILY=fastapi-health-ecs
export CONTAINER_NAME=app
export CONTAINER_PORT=8011
export ECR_IMAGE_URI=<account>.dkr.ecr.us-west-2.amazonaws.com/fastapi-health-ecs:latest

./scripts/render-task-def.sh > task-def.json
```

---

## License

MIT
