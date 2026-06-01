#!/bin/bash
set -euo pipefail

readonly TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${TF_DIR}/../../scripts"

source "${SCRIPTS_DIR}/common.sh"

refresh_state_bucket_credentials() {
  local access_key
  local secret_key
  cd "${TF_DIR}"
  access_key="$(tofu output -raw bucket_spaces_access_key_local 2>/dev/null || true)"
  secret_key="$(tofu output -raw bucket_spaces_secret_key_local 2>/dev/null || true)"
  if [[ -n "${access_key}" && -n "${secret_key}" ]]; then
    update_local_aws_credentials \
      "${SCRIPTS_DIR}/../.aws/credentials" "digitalocean-spaces" \
      "${access_key}" "${secret_key}"
  fi
}

"${SCRIPTS_DIR}/apply.sh" "${TF_DIR}" "foundation/digitalocean-remote-state"
refresh_state_bucket_credentials
