#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Load helpers
COMMON_SH="${ROOT_DIR}/../../scripts/common.sh"
if [[ -f "${COMMON_SH}" ]]; then
  source "${COMMON_SH}"
else
  echo "[ERROR] Helper not found at path: ${COMMON_SH}"
  exit 1
fi

# Get local AWS credentials needed for remote state
AWS_CREDENTIALS_FILE="${ROOT_DIR}/../.aws/credentials"
AWS_PROFILE="digitalocean-spaces"
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
if ! get_local_aws_credentials "${AWS_CREDENTIALS_FILE}" "${AWS_PROFILE}" AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; then
  echo "[ERROR] Unable to load local AWS credentials for profile ${AWS_PROFILE}" >&2
  exit 1
fi

# Deploy the terraform project with the local AWS credentials for remote state
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

exec ./apply.sh

# Update local AWS credentials after the new deployment
ACCESS_KEY_LOCAL=$(terraform output -raw bucket_spaces_access_key_local 2>/dev/null || echo "")
SECRET_KEY_LOCAL=$(terraform output -raw bucket_spaces_secret_key_local 2>/dev/null || echo "")
if [[ -n "${ACCESS_KEY_LOCAL}" && -n "${SECRET_KEY_LOCAL}" ]]; then
  update_local_aws_credentials "${AWS_CREDENTIALS_FILE}" "${AWS_PROFILE}" "${ACCESS_KEY_LOCAL}" "${SECRET_KEY_LOCAL}"
else
  echo "[WARNING] Could not extract remote state bucket Spaces credentials for local usage from Terraform outputs." >&2
fi
