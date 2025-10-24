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

load_env "${ROOT_DIR}/../.env"

# Generate backend.hcl from bucket region and name
SHARED_BACKEND_HCL="${ROOT_DIR}/../backend.hcl"
generate_backend_file "${TF_VAR_region}" "${TF_VAR_bucket_name}" "${SHARED_BACKEND_HCL}"

# Standard init/plan/show/apply
STATE_KEY="foundation/digitalocean-remote-state/terraform.tfstate"
terraform_deploy "${SHARED_BACKEND_HCL}" "${STATE_KEY}" --migrate-state