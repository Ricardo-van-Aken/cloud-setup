#!/bin/bash
set -euo pipefail

# Universal apply script for all steps (except bootstrap for remote state).
# Usage: apply.sh <step_dir> <state_key>

readonly STEP_DIR="${1:?Usage: apply.sh <step_dir> <state_key>}"
readonly STATE_KEY="${2:?Usage: apply.sh <step_dir> <state_key>}"
readonly SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${SCRIPTS_DIR}/common.sh"

setup_credentials() {
  load_env "${SCRIPTS_DIR}/../.env"

  AWS_ACCESS_KEY_ID=""
  AWS_SECRET_ACCESS_KEY=""
  if ! get_local_aws_credentials \
      "${SCRIPTS_DIR}/../.aws/credentials" "digitalocean-spaces" \
      AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; then
    echo "[ERROR] Unable to load local AWS credentials for profile digitalocean-spaces" >&2
    return 1
  fi
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
}

deploy() {
  local backend_hcl="${SCRIPTS_DIR}/../backend.hcl"
  local ephemerals_state_key="${STATE_KEY%/terraform.tfstate}/ephemerals.tfstate"

  generate_backend_file "${TF_VAR_region}" "${TF_VAR_bucket_name}" "${backend_hcl}"
  cd "${STEP_DIR}"
  terraform_apply_ephemerals "${backend_hcl}" "${ephemerals_state_key}"
  terraform_deploy "${backend_hcl}" "${STATE_KEY}"
  terraform_destroy_ephemerals
}

refresh_local_credentials() {
  local access_key
  local secret_key
  access_key="$(tofu output -raw bucket_spaces_access_key_local 2>/dev/null || true)"
  secret_key="$(tofu output -raw bucket_spaces_secret_key_local 2>/dev/null || true)"
  if [[ -n "${access_key}" && -n "${secret_key}" ]]; then
    update_local_aws_credentials \
      "${SCRIPTS_DIR}/../.aws/credentials" "digitalocean-spaces" \
      "${access_key}" "${secret_key}"
  fi
}

main() {
  setup_credentials
  deploy
  refresh_local_credentials
}

main
