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

# Ensure backend file is disabled
BACKEND_FILE="backend.tf"
if [[ -f ${BACKEND_FILE} ]]; then mv "${BACKEND_FILE}" "${BACKEND_FILE}.disabled"; fi

# Standard init/plan/show/apply
load_env "${ROOT_DIR}/../.env"
if ! terraform init; then
    echo "[WARNING] Terraform init with local state failed."
    # Ensure backend file is present(since we disabled it earlier)
    BACKEND_FILE="backend.tf"
    if [[ -f ${BACKEND_FILE}.disabled ]]; then mv "${BACKEND_FILE}.disabled" "${BACKEND_FILE}"; fi
    exit 1
else
    echo "[INFO] Terraform init with local state successful."
fi

echo "[INFO] Terraform plan"
terraform plan -out ".tfplan.local" >/dev/null

echo "[INFO] Terraform showing plan preview."
terraform show ".tfplan.local" || true

read -r -p "Proceed with apply using this plan? [y/N] " CONFIRM
case "${CONFIRM}" in
    y|Y|yes|YES)
        terraform apply ".tfplan.local"
    ;;
    *)
        echo "[INFO] Aborting by user choice."
        # Ensure backend file is present(since we disabled it earlier)
        BACKEND_FILE="backend.tf"
        if [[ -f ${BACKEND_FILE}.disabled ]]; then mv "${BACKEND_FILE}.disabled" "${BACKEND_FILE}"; fi
        exit 0
    ;;
esac

# Update local AWS credentials after the new deployment
echo "[INFO] Updating local AWS credentials after the new deployment."
ACCESS_KEY_LOCAL=$(terraform output -raw bucket_spaces_access_key_local 2>/dev/null || echo "")
SECRET_KEY_LOCAL=$(terraform output -raw bucket_spaces_secret_key_local 2>/dev/null || echo "")
if [[ -n "${ACCESS_KEY_LOCAL}" && -n "${SECRET_KEY_LOCAL}" ]]; then
  update_local_aws_credentials "${ROOT_DIR}/../.aws/credentials" "digitalocean-spaces" "${ACCESS_KEY_LOCAL}" "${SECRET_KEY_LOCAL}"
else
  echo "[WARNING] Could not extract remote state bucket Spaces credentials for local usage from Terraform outputs." >&2
  exit 1
fi

# Get local AWS credentials needed for remote state
export AWS_ACCESS_KEY_ID="${ACCESS_KEY_LOCAL}"
export AWS_SECRET_ACCESS_KEY="${SECRET_KEY_LOCAL}"

# Ensure backend file is present(since we disabled it earlier)
BACKEND_FILE="backend.tf"
if [[ -f ${BACKEND_FILE}.disabled ]]; then mv "${BACKEND_FILE}.disabled" "${BACKEND_FILE}"; fi

# Generate backend.hcl from bucket region and name
SHARED_BACKEND_HCL="${ROOT_DIR}/../backend.hcl"
generate_backend_file "${TF_VAR_region}" "${TF_VAR_bucket_name}" "${SHARED_BACKEND_HCL}"

# After successful apply, migrate state from local to remote, so later runs use remote state.
STATE_KEY="foundation/01-digitalocean-remote-state/terraform.tfstate"
echo "[INFO] Migrating state from local to remote."
if ! terraform init -backend-config="${SHARED_BACKEND_HCL}" -backend-config="key=${STATE_KEY}" -migrate-state; then
    echo "[WARNING] Terraform init with remote state failed."
    exit 1
else
    echo "[INFO] Terraform init with remote state successful."
fi

# Clean up local state
cleanup_local_state .
