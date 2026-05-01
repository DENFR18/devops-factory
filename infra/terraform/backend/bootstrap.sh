#!/usr/bin/env bash
# Bootstrap — run ONCE per environment to create the remote state buckets.
# After this, each environment's backend.tf points to the created bucket.
#
# Prerequisites:
#   SCW_ACCESS_KEY, SCW_SECRET_KEY, SCW_DEFAULT_PROJECT_ID must be set.
#   terraform >= 1.7 must be in PATH.
#
# Usage: ./bootstrap.sh <env> [region]

set -euo pipefail

ENV="${1:?Usage: $0 <env> [region]   (env: dev | prod)}"
REGION="${2:-fr-par}"
ZONE="${REGION}-1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! "${ENV}" =~ ^(dev|prod)$ ]]; then
  echo "ERROR: env must be dev or prod" >&2
  exit 1
fi

for var in SCW_ACCESS_KEY SCW_SECRET_KEY SCW_DEFAULT_PROJECT_ID; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: ${var} is not set" >&2
    exit 1
  fi
done

echo "==> Bootstrapping Terraform state backend for env=${ENV} region=${REGION}"
cd "${SCRIPT_DIR}"

terraform init -upgrade

terraform apply \
  -var "env=${ENV}" \
  -var "region=${REGION}" \
  -var "zone=${ZONE}" \
  -var "project_id=${SCW_DEFAULT_PROJECT_ID}" \
  -auto-approve

echo ""
echo "==> Done. Add this to environments/${ENV}/backend.tf:"
echo ""
echo '  backend "s3" {'
echo "    bucket                      = \"devops-factory-tfstate-${ENV}\""
echo "    key                         = \"terraform.tfstate\""
echo "    region                      = \"${REGION}\""
echo "    endpoint                    = \"https://s3.${REGION}.scw.cloud\""
echo "    skip_credentials_validation = true"
echo "    skip_region_validation      = true"
echo "    skip_requesting_account_id  = true"
echo '  }'
