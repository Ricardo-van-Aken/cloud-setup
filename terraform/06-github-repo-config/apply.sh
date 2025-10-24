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

load_env "${ROOT_DIR}/../.env"

# Generate backend.hcl from bucket region and name
SHARED_BACKEND_HCL="${ROOT_DIR}/../backend.hcl"
generate_backend_file "${TF_VAR_region}" "${TF_VAR_bucket_name}" "${SHARED_BACKEND_HCL}"

# Standard init/plan/show/apply
STATE_KEY="foundation/06-github-repo-config/terraform.tfstate"
terraform_deploy "${SHARED_BACKEND_HCL}" "${STATE_KEY}"
