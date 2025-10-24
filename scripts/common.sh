#!/usr/bin/env bash
set -euo pipefail

# Common Terraform helper functions for apply scripts

# Load environment variables from .env file
load_env() {
  local env_file="${1:-.env}"
  
  if [[ -f "${env_file}" ]]; then
    echo "[INFO] Loading environment variables from ${env_file}" >&2
    set -a
    source "${env_file}"
    set +a
    echo "[SUCCESS] Environment variables loaded" >&2
  else
    echo "[WARNING] Environment file not found: ${env_file}" >&2
    echo "[INFO] Make sure to set TF_VAR_* variables manually or create .env file" >&2
  fi
}

# Generate backend.hcl from bucket region and name
generate_backend_file() {
  local spaces_region="${1:-}"
  local bucket_name="${2:-}"
  local backend_file="${3:-backend.hcl}"

  if [[ -z "${bucket_name}" ]]; then
    echo "[ERROR] Bucket name is required to generate backend.hcl" >&2
    return 1
  fi
  
  echo "[INFO] Generating ${backend_file} with bucket name: ${bucket_name}" >&2
  
  cat > "${backend_file}" << EOF
# Shared backend configuration for DigitalOcean Spaces (S3-compatible)

endpoints = {
	s3 = "https://${spaces_region}.digitaloceanspaces.com"
}

bucket  = "${bucket_name}"
region  = "us-east-1"

# AWS-specific checks disabled for Spaces
skip_credentials_validation = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_s3_checksum            = true

# Enable lockfile-based state locking in Spaces (Terraform >= 1.11)
use_lockfile = true
EOF

  echo "[SUCCESS] Generated ${backend_file}" >&2
}

# check_aws_credentials AWS_CREDENTIALS_FILE AWS_PROFILE
# Returns 0 if credentials file exists and contains the profile, else 1
check_local_aws_credentials() {
  local credentials_file="$1"
  local profile_name="$2"

  echo "[INFO] Checking if AWS credentials exist with DigitalOcean Spaces profile." >&2

  if [[ -f "${credentials_file}" ]]; then
    if grep -q "\\[${profile_name}\\]" "${credentials_file}"; then
      echo "[SUCCESS] Found AWS credentials file with DigitalOcean Spaces profile." >&2
      return 0
    else
      echo "[WARNING] AWS credentials file found, but does not have DigitalOcean Spaces profile." >&2
    fi
  else
    echo "[WARNING] AWS credentials file not found: ${credentials_file}" >&2
  fi

  return 1
}

get_local_aws_credentials() {
  local credentials_file="$1"
  local profile_name="$2"
  local -n aws_access_key_id="$3"
  local -n aws_secret_access_key="$4"

  echo "[INFO] Getting local AWS credentials for profile: ${profile_name}" >&2
  
  # Check if awk is installed
  if ! command -v awk >/dev/null 2>&1; then
    echo "[ERROR] awk is required" >&2
    exit 1
  fi

  # Check if local credentials file exists
  if ! check_local_aws_credentials "${credentials_file}" "${profile_name}"; then
    echo "[ERROR] Credentials file not found: ${credentials_file}" >&2
    return 1
  fi

  # Read AWS keys from local credentials file
  aws_access_key_id=$(awk -v p="${profile_name}" 'BEGIN{f=0} $0=="["p"]"{f=1;next} f&&/^aws_access_key_id/{print $3; exit}' "${credentials_file}" || true)
  aws_secret_access_key=$(awk -v p="${profile_name}" 'BEGIN{f=0} $0=="["p"]"{f=1;next} f&&/^aws_secret_access_key/{print $3; exit}' "${credentials_file}" || true)
  
  if [[ -z "${aws_access_key_id}" || -z "${aws_secret_access_key}" ]]; then
    echo "[ERROR] Failed to read AWS credentials for profile ${profile_name} from ${credentials_file}" >&2
    return 1
  fi

  return 0
}

update_local_aws_credentials() {
  local credentials_file="$1"
  local profile_name="$2"
  local access_key_local="$3"
  local secret_key_local="$4"

  echo "[INFO] Updating local AWS credentials file (profile: ${profile_name})." >&2

  local credentials_dir
  credentials_dir="$(dirname "${credentials_file}")"
  mkdir -p "${credentials_dir}"

  # Create file if missing
  if [[ ! -f "${credentials_file}" ]]; then
    touch "${credentials_file}"
  fi

  # Remove existing profile block (if present)
  # shellcheck disable=SC2016
  sed -i.bak "/\\[${profile_name}\\]/,/^\\[/ { /\\[${profile_name}\\]/d; /^\\[/!d; }" "${credentials_file}" || true

  # Append updated profile block
  {
    echo "[${profile_name}]"
    echo "aws_access_key_id = ${access_key_local}"
    echo "aws_secret_access_key = ${secret_key_local}"
  } >> "${credentials_file}"

  rm -f "${credentials_file}.bak"
  echo "[INFO] Local AWS credentials updated." >&2
}

terraform_deploy() {
  local shared_backend_hcl="$1"
  local state_key="$2"
  local init_args="${3:-}"

  echo "[INFO] Terraform deploying with shared backend config: ${shared_backend_hcl} and state key: ${state_key}" >&2
  
  # Validate shared backend file exists
  if [[ ! -f "${shared_backend_hcl}" ]]; then
    echo "[ERROR] Backend file for remote state not found: ${shared_backend_hcl}"
    return 1
  fi
  # Validate AWS credentials are present
  if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    echo "[ERROR] Missing AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY in environment."
    return 1
  fi

  # Initialize passing shared backend config and a unique key for this stack
  if ! terraform init -backend-config="${shared_backend_hcl}" -backend-config="key=${state_key}" ${init_args:-}; then
    echo "[ERROR] Terraform init with remote state failed." >&2
    return 1
  else
    echo "[INFO] Terraform init with remote state successful." >&2
  fi

  echo "[INFO] Terraform plan"
  terraform plan -out ".tfplan.local" >/dev/null

  echo "[INFO] Terraform showing plan preview." >&2
  terraform show ".tfplan.local" || true

  read -r -p "Proceed with apply using this plan? [y/N] " CONFIRM
  case "${CONFIRM}" in
    y|Y|yes|YES)
      terraform apply ".tfplan.local"
      ;;
    *)
      echo "[INFO] Aborting by user choice." >&2
      return 2
      ;;
  esac
}

terraform_destroy() {
  local shared_backend_hcl="$1"
  local state_key="$2"
  local init_args="${3:-}"

  echo "[INFO] Terraform destroying with shared backend config: ${shared_backend_hcl} and state key: ${state_key}" >&2
  
  # Validate shared backend file exists
  if [[ ! -f "${shared_backend_hcl}" ]]; then
    echo "[ERROR] Backend file for remote state not found: ${shared_backend_hcl}"
    return 1
  fi
  # Validate AWS credentials are present
  if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    echo "[ERROR] Missing AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY in environment."
    return 1
  fi

  # Initialize passing shared backend config and a unique key for this stack
  if ! terraform init -backend-config="${shared_backend_hcl}" -backend-config="key=${state_key}" ${init_args:-}; then
    echo "[ERROR] Terraform init with remote state failed." >&2
    return 1
  else
    echo "[INFO] Terraform init with remote state successful." >&2
  fi

  echo "[INFO] Terraform plan for destroy"
  terraform plan -destroy -out ".tfplan.local" >/dev/null

  echo "[INFO] Terraform showing destroy plan preview." >&2
  terraform show ".tfplan.local" || true

  read -r -p "Proceed with destroy using this plan? [y/N] " CONFIRM
  case "${CONFIRM}" in
    y|Y|yes|YES)
      terraform apply ".tfplan.local"
      ;;
    *)
      echo "[INFO] Aborting by user choice." >&2
      return 2
      ;;
  esac
}

cleanup_local_state() {
  local cleanup_dir="${1:-.}"

  echo "[INFO] Cleaning up local Terraform plan and state files securely in ${cleanup_dir}." >&2
  
  if [[ ! -d "${cleanup_dir}" ]]; then
    echo "[ERROR] Directory does not exist: ${cleanup_dir}" >&2
    return 1
  fi

  if command -v shred >/dev/null 2>&1; then
    if [[ -f "${cleanup_dir}/terraform.tfstate" ]]; then shred -u -n 3 -z -- "${cleanup_dir}/terraform.tfstate"; fi
    if [[ -f "${cleanup_dir}/terraform.tfstate.backup" ]]; then shred -u -n 3 -z -- "${cleanup_dir}/terraform.tfstate.backup"; fi
  else
    echo "[WARNING] shred is not installed, skipping secure deletion of local Terraform plan and state files." >&2
  fi
}

