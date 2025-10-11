# Cloud Setup Foundation

This repository bootstraps the foundational cloud resources for an organization so future projects can deploy reliably. It provisions:

- S3-compatible bucket in DigitalOcean Spaces for Terraform remote state
- GitHub organization configuration for CI and secrets
- A GitHub repository to host this very code, wired for re-runs via CI

## Prerequisites

- Bash shell (Linux/macOS, or Windows via WSL/Git Bash)
- Terraform ~> 1.11
- DigitalOcean account and API token (personal access token):
  
  **DigitalOcean Token**
  - Read/Write access to Projects
  - Read/Write access to Spaces (Object Storage)
  - Read/Write access to Spaces Keys
- GitHub organization and two fine‑grained personal access tokens:
  
  **Organization Token** (used in Step 2)
  - Repository access: Public repositories
  - Organizations: Read/Write to Secrets
  - Organizations: Read/Write to Variables
  
  **Repository Token** (used in Step 3)
  - Repository access: All repositories (first run), or the created repository on subsequent runs
  - Repositories: Read/Write to Administration
  - Repositories: Read/Write to Contents
  - Repositories: Read/Write to Secrets
  - Repositories: Read/Write to Variables

## Repository Layout

- `terraform/01-digitalocean-remote-state/` — creates the Spaces bucket and access keys for Terraform remote state
- `terraform/02-github-organization/` — configures org‑level GitHub Actions secrets/variables for remote state
- `terraform/03-github-foundation-repo/` — creates a repository for this codebase and seeds CI variables
- `terraform/.env.example` — template for environment variables (copy to `.env` and fill in your values)
- `scripts/common.sh` — shared helper functions for Terraform deployment

## Getting started
Step 1 - 3 are first ran locally and require local environment variables. First, copy the environment template and fill in your values:

```bash
cd terraform
cp .env.example .env
# Edit .env with your actual values
```

### Step 1: Create remote state in DigitalOcean
This step creates the AWS-compatible Spaces bucket and two keys for accessing this bucket. One of the keys is automatically added as plaintext in `terraform/.aws/credentials`, since the next steps require this key.

```
cd ./terraform
./01-digitalocean-remote-state/01_apply_local-credentials-and-state.sh
```
After apply, the script migrates state to the Spaces backend and securely removes local state artifacts.

Optional re-apply later (now using remote state):
```
./01-digitalocean-remote-state/02_apply_local-credentials.sh
```
Use this only if you need to make further changes to the remote‑state stack before proceeding.

### Step 2: Configure GitHub organization secrets/variables
This step configures your GitHub organization to hold the remote state access keys as org‑level secrets/variables used by CI runners.

```
./02-github-organization/01_apply_local-credentials.sh
```

### Step 3: Create the foundation repository in GitHub
This step creates a repository for this codebase and configures the variables needed for CI re‑runs of this and prior steps.

```
./03-github-foundation-repo/01_apply_with_local_credentials.sh
```

### CI Re‑runs

Each directory includes an `apply.sh` that can be executed by GitHub Actions.

The local wrapper scripts (`01_*` / `02_*`) simply export local AWS credentials for remote state, and local environment variables, and call the corresponding `./apply.sh`.

With the workflows in `.github/`, CI can re‑run the same deployments using the org secrets/variables configured in Step 2.

### Later steps and Cleanup

### Notes

- Remote state backend configuration is generated dynamically by the `generate_backend_file` function in `scripts/common.sh`
- Scripts securely clean up local state files after successful migration to remote state. If `shred` is not available, cleanup is skipped with a warning.

## Design decisions