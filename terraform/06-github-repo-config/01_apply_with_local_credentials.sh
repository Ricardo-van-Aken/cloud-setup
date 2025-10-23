#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Load common helpers
COMMON_SH="${ROOT_DIR}/../../scripts/common.sh"
if [[ -f "${COMMON_SH}" ]]; then
  source "${COMMON_SH}"
else
  echo "[ERROR] Common helper not found: ${COMMON_SH}"
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
