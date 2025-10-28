# Cloud Setup Foundation

This repository bootstraps the foundational cloud resources for an organization so future projects can deploy reliably. It provisions:

- S3-compatible bucket in DigitalOcean Spaces for Terraform remote state
- GitHub organization configuration for CI/CD (teams and org-level secrets/variables)
- A GitHub repository to host this very code, wired for re-runs via CI
- Repository-level variables and secrets for CI re-runs

## Prerequisites

- Bash shell (Linux/macOS, or Windows via WSL/Git Bash)
- Terraform ~> 1.11
- DigitalOcean account and API token (personal access token):

  **DigitalOcean Token**
  - Read/Write access to Projects
  - Read/Write access to Spaces (Object Storage)
  - Read/Write access to Spaces Keys

- GitHub organization and four fine‑grained personal access tokens:
  
  **GitHub Org Config Token** (used in Step 2)
  - Repository access: No access needed
  - Organizations: Read/Write to Members
  
  **GitHub Org Vars Token** (used in Step 3)
  - Repository access: No access needed
  - Organizations: Read/Write to Secrets
  - Organizations: Read/Write to Variables
  
  **GitHub Repo Token** (used in Step 4)
  - Repository access: All repositories
  - Repositories: Read/Write to Administration
  - Repositories: Read/Write to Contents
  - Repositories: Read/Write to Actions
  - Organizations: Read/Write to Members
  
  **GitHub Repo Vars Token** (used in Step 5)
  - Repository access: All repositories 
  - Repositories: Read/Write to Secrets
  - Repositories: Read/Write to Variables

## Repository Layout

- `foundation/terraform/01-digitalocean-remote-state/` — creates the Spaces bucket and access keys for Terraform remote state
- `foundation/terraform/02-github-org-config/` — configures GitHub organization teams and structure
- `foundation/terraform/03-github-org-vars/` — configures organization‑level secrets/variables for remote state
- `foundation/terraform/04-github-repo/` — creates a repository for this codebase with branch protection and environments
- `foundation/terraform/05-github-repo-vars/` — configures repository-level variables and secrets for CI re-runs
- `foundation/scripts/common.sh` — shared helper functions for Terraform deployment

## Getting started

Foundation steps 1-5 are first run locally and require local environment variables. Each step needs specific tokens set as environment variables.
```bash
cd foundation/terraform
cp .env.example .env
# Edit .env with your actual values
```

### Step 1: Create remote state in DigitalOcean
This step creates the AWS-compatible Spaces bucket and two keys for accessing this bucket. One of the keys is automatically added as plaintext in `foundation/terraform/.aws/credentials`, since the next steps require this key.

```bash
# from the foundation/terraform/ directory:
./01-digitalocean-remote-state/apply_local-credentials-and-state.sh
```
After apply, the script migrates state to the Spaces backend and securely removes local state artifacts. If `shred` is not available, cleanup is skipped with a warning.

Optional re-apply later (now using remote state):
```bash
# from the foundation/terraform/ directory:
./01-digitalocean-remote-state/apply_local-credentials.sh
```
Use this only if you need to make further changes to the remote‑state infrastructure before proceeding.

### Step 2: Configure GitHub organization teams
This step creates the organization team structure (DevOps, Development, QA teams and their sub-teams).

```bash
# from the foundation/terraform/ directory:
./02-github-org-config/apply_with_local_credentials.sh
```

### Step 3: Configure GitHub organization secrets/variables
This step configures your GitHub organization to hold the remote state access keys as org‑level secrets/variables used by CI runners.

```bash
# from the foundation/terraform/ directory:
./03-github-org-vars/apply_local-credentials.sh
```

### Step 4: Create the clouds setup foundation repository in GitHub
This step creates a repository for this codebase with branch protection, environments, and team access.

```bash
# from the foundation/terraform/ directory:
./04-github-repo/apply_with_local_credentials.sh
```


### Step 5: Configure repository secrets/variables
This step seeds repository-level variables and secrets needed for CI runs of this projects terraform.

```bash
# from the foundation/terraform/ directory:
./05-github-repo-vars/apply_with_local_credentials.sh
```

### CI Re‑runs

The local wrapper scripts (`apply_local-credentials.sh`) export local AWS credentials for remote state, and local environment variables, then call the corresponding `./apply.sh`. When the local run of the terraform has finished, any re-runs can be done through the github workflows in the `.github/workflows/` directory. These workflows use the organization and repository secrets/variables that have been configured during the local run.

### Notes

- Remote state backend configuration is generated dynamically by the `generate_backend_file` function in `foundation/scripts/common.sh`
- The steps must be completed in order as some of these steps depend on outputs from previous steps

## Extra infrastructure

Future: This piece of documentation will contain the instructions for setting up extra organizational infrastructure, such as a secret manager, container registry, remote docker build cache, monitoring services, Identity and Access Management.

Any of this extra infrastructure should be ran through ci runners with proper secret management.

## Creating repositories for a new project

