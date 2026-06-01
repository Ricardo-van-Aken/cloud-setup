#!/bin/bash
set -euo pipefail

# Bootstrap script: used only for the very first run when no remote state bucket
# exists yet. Ephemerals and main terraform both use local state, then main state
# is migrated to remote.

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SHARED_DIR="$(dirname "${ROOT_DIR}")"
cd "${ROOT_DIR}"

source "${ROOT_DIR}/../../scripts/common.sh"
load_env "${SHARED_DIR}/.env"

readonly BACKEND_HCL="${SHARED_DIR}/backend.hcl"
readonly STATE_KEY="foundation/digitalocean-remote-state/terraform.tfstate"
readonly BACKEND_FILE="backend.tf"

# Apply ephemerals with local state (remote bucket does not exist yet).
terraform_apply_ephemerals

# Disable remote backend for local-state apply.
if [[ -f "${BACKEND_FILE}" ]]; then mv "${BACKEND_FILE}" "${BACKEND_FILE}.disabled"; fi

if ! tofu init; then
  if [[ -f "${BACKEND_FILE}.disabled" ]]; then mv "${BACKEND_FILE}.disabled" "${BACKEND_FILE}"; fi
  exit 1
fi

tofu plan -out ".tfplan.local" >/dev/null
tofu show ".tfplan.local" || true

confirm=""
read -r -p "Proceed with apply using this plan? [y/N] " confirm
case "${confirm}" in
  y|Y|yes|YES)
    tofu apply ".tfplan.local"
    ;;
  *)
    echo "[INFO] Aborting by user choice." >&2
    if [[ -f "${BACKEND_FILE}.disabled" ]]; then mv "${BACKEND_FILE}.disabled" "${BACKEND_FILE}"; fi
    exit 0
    ;;
esac

# Store bucket-specific credentials locally for subsequent runs.
local_access_key=""
local_secret_key=""
local_access_key="$(tofu output -raw bucket_spaces_access_key_local 2>/dev/null || true)"
local_secret_key="$(tofu output -raw bucket_spaces_secret_key_local 2>/dev/null || true)"
if [[ -n "${local_access_key}" && -n "${local_secret_key}" ]]; then
  update_local_aws_credentials \
    "${SHARED_DIR}/.aws/credentials" "digitalocean-spaces" \
    "${local_access_key}" "${local_secret_key}"
else
  echo "[WARNING] Could not extract remote state bucket Spaces credentials." >&2
  exit 1
fi

export AWS_ACCESS_KEY_ID="${local_access_key}"
export AWS_SECRET_ACCESS_KEY="${local_secret_key}"

# Re-enable backend and migrate state to remote.
if [[ -f "${BACKEND_FILE}.disabled" ]]; then mv "${BACKEND_FILE}.disabled" "${BACKEND_FILE}"; fi
generate_backend_file "${TF_VAR_region}" "${TF_VAR_bucket_name}" "${BACKEND_HCL}"

if ! tofu init \
    -backend-config="${BACKEND_HCL}" \
    -backend-config="key=${STATE_KEY}" \
    -migrate-state; then
  exit 1
fi

# Destroy ephemerals now that main state is safely in remote.
terraform_destroy_ephemerals
cleanup_local_state .
