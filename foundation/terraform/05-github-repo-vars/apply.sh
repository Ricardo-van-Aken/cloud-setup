#!/bin/bash
readonly TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly STATE_DIR="foundation/github-repo-vars"
exec "${TF_DIR}/../../scripts/apply.sh" "${TF_DIR}" "${STATE_DIR}"
