#!/bin/bash
set -euo pipefail

# Universal OpenTofu apply script.
# Usage: apply.sh <tf_dir> <state_dir>

readonly TF_DIR="${1:?Usage: apply.sh <step_dir> <state_dir>}"
readonly STATE_DIR="${2:?Usage: apply.sh <step_dir> <state_dir>}"
readonly SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${SCRIPTS_DIR}/common.sh"

setup_state_bucket_credentials() {
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
  local state_key="${STATE_DIR}/terraform.tfstate"
  local ephemerals_state_key="${STATE_DIR}/ephemerals.tfstate"

  generate_backend_file "${TF_VAR_region}" "${TF_VAR_bucket_name}" "${backend_hcl}"
  cd "${TF_DIR}"
  terraform_apply_ephemerals "${backend_hcl}" "${ephemerals_state_key}"
  terraform_deploy "${backend_hcl}" "${state_key}"
  terraform_destroy_ephemerals
}

main() {
  setup_state_bucket_credentials
  deploy
}

main
