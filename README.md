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

### Build (local arm64 on Apple Silicon)

```bash
docker buildx build --platform linux/arm64 -t fastapi-health-ecs:local --load .
```

### Build (linux/amd64 for cloud)

```bash
docker buildx build --platform linux/amd64 -t fastapi-health-ecs:latest .
```

### Run locally

```bash
docker run --rm -p 8011:8011 fastapi-health-ecs:local
```

### Build and push multi-arch (recommended for ECR)

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <ECR_URI> --push .
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

The ALB security group must allow inbound TCP 8011 from the internet. The ECS service security group is created by Terraform and only allows traffic from the ALB.

```bash
cd terraform
terraform init
terraform plan \
  -var="aws_region=us-west-2" \
  -var="vpc_id=<vpc-id>" \
  -var='public_subnet_ids=["<subnet-a>","<subnet-b>"]' \
  -var="alb_security_group_id=<sg-id>"

terraform apply \
  -var="aws_region=us-west-2" \
  -var="vpc_id=<vpc-id>" \
  -var='public_subnet_ids=["<subnet-a>","<subnet-b>"]' \
  -var="alb_security_group_id=<sg-id>"
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

## AWS Console checklist (us-west-2)

- ECR → Repositories → `fastapi-health-ecs` (image `latest`)
- ECS → Clusters → `fastapi-health` → Services → `fastapi-health` (1 running task)
- EC2 → Load Balancers → `fastapi-health-alb` (listener on 8011) and Target Group `fastapi-health-tg`
- EC2 → Security Groups → `fastapi-health-svc` and ALB SG `sg-047d2a7bbda9dd56d` (ingress 8011/80)
- IAM → Roles → `fastapi-health-exec`
- CloudWatch → Log groups → `/ecs/fastapi-health`

---

## Operational notes

- If the ALB listener uses port 8011, ensure the ALB security group allows inbound TCP 8011 from the internet (we added this on `sg-047d2a7bbda9dd56d`).
- If an ALB already exists, import it into Terraform before applying to avoid name conflicts.
- Before destroying the stack, delete images in the ECR repo or enable `force_delete` to avoid RepositoryNotEmpty errors.
- ECS service runs in the provided public subnets with `assign_public_ip=true`; the ECS service security group only permits 8011 inbound from the ALB SG.

---

## License

MIT
