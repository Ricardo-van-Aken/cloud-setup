#!/bin/bash
STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${STEP_DIR}/../../scripts/apply.sh" "${STEP_DIR}" "foundation/github-org-config/terraform.tfstate"
