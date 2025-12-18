# Repository Guidelines

## Project Structure & Module Organization

This repository is currently a minimal scaffold (only `README.md` is tracked). No application, infrastructure, or test modules are checked in yet. As you add code, keep FastAPI and Terraform concerns separated and document the layout here (for example, an API package and an infrastructure folder). Maintain a small, predictable top-level structure and avoid burying entry points deeply.

## Build, Test, and Development Commands

There are no committed build or test scripts yet. When adding tooling, prefer a single entry point such as a `Makefile` or `scripts/` folder and keep commands explicit. Example patterns to document once added:

- `python -m uvicorn app.main:app --reload` for local API runs.
- `python -m pytest` for unit/integration tests.
- `terraform init` / `terraform plan` / `terraform apply` from the infra directory.

## Coding Style & Naming Conventions

No formatter or linter is configured today. When introducing Python or Terraform, add clear formatting rules and keep them consistent across the repo. Common, readable defaults are 4-space indentation for Python and 2-space indentation for HCL. Use descriptive module names (e.g., `app/routers/`, `infra/modules/`) and avoid abbreviations that hide intent.

## Testing Guidelines

No test framework is currently configured. If tests are added, place them in a dedicated `tests/` directory and follow standard naming conventions such as `test_*.py`. Document any coverage goals in this file and ensure local commands are one-liners.

## Commit & Pull Request Guidelines

There is only a single initial commit, so no convention is established. If you introduce a style (e.g., Conventional Commits), note it here and apply it consistently. For pull requests, include a clear description of changes, any required configuration steps, and links to related issues or tickets.

## Security & Configuration Tips

Do not commit secrets or environment-specific values. Store local credentials in files such as `.env` or `terraform.tfvars` and ensure they are ignored by Git. Document any required environment variables and sample configuration files.
