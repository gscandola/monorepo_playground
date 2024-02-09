#!/usr/bin/env bash
set -o errexit -o pipefail

#$TARGET_PACKAGES format should be JSON compliant: ["a","b"]
target_packages="$TARGET_PACKAGES"

echo "Installing yq..."
curl -s -L -o yq "https://github.com/mikefarah/yq/releases/download/v4.40.7/yq_linux_amd64"
chmod +x ./yq
mkdir -p "${HOME}/.local/bin"
mv ./yq "${HOME}/.local/bin/"

# We use yq to replace the package key, this is the only edit in place we need
yq e ".workflows.build_deploy_preview.jobs[0].\"build-preview\".matrix.parameters.\"package\" = $target_packages" -i .circleci/continue_config.yml
yq e ".workflows.build_deploy_preview.jobs[0].\"deploy-preview\".matrix.parameters.\"package\" = $target_packages" -i .circleci/continue_config.yml