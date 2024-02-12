#!/usr/bin/env bash
set -o errexit -o pipefail

echo "Installing yq..."
curl -s -L -o yq "https://github.com/mikefarah/yq/releases/download/v4.40.7/yq_linux_amd64"
chmod +x ./yq
mkdir -p "${HOME}/.local/bin"
mv ./yq "${HOME}/.local/bin/"

# We use yq to replace the package key, this is the only edit in place we need
# TODO find a clever way to target appropriate job instead of using numeric index
yq e ".workflows.build_deploy_preview.jobs[0].\"build-preview\".matrix.parameters.\"package\" = $TARGET_PACKAGES" -i .circleci/continue_config.yml
# TODO find a clever way to target appropriate job instead of using numeric index
yq e ".workflows.build_deploy_preview.jobs[1].\"deploy-preview\".matrix.parameters.\"package\" = $TARGET_PACKAGES" -i .circleci/continue_config.yml

# Release Type param
yq e ".parameters.releaseType.default = \"$RELEASE_TYPE\"" -i .circleci/continue_config.yml

# Debug
cat .circleci/continue_config.yml