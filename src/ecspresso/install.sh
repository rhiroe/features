#!/bin/bash
set -e

# The install.sh script is the installation entrypoint for any dev container 'features' in this repository. 
#
# The tooling will parse the devcontainer-features.json + user devcontainer, and write 
# any build-time arguments into a feature-set scoped "devcontainer-features.env"
# The author is free to source that file and use it however they would like.
set -a
. ./devcontainer-features.env
set +a

if [ "${ECSPRESSOVERSION}" = "latest" ]; then
    ECSPRESSO_VERSION="2.4.1"
else
    ECSPRESSO_VERSION="${ECSPRESSOVERSION:-"2.4.1"}"
fi
ECSPRESSO_DOWNLOAD_URL=https://github.com/kayac/ecspresso/releases/download/v${ECSPRESSO_VERSION}/ecspresso_${ECSPRESSO_VERSION}_linux_amd64.tar.gz
JQ_DOWNLOAD_URL=https://github.com/stedolan/jq/releases/latest/download/jq-linux64
YQ_DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
SESSION_MANAGER_PLUGIN_DOWNLOAD_URL=https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb

apt update && \
apt install -y ca-certificates wget && \
rm -rf /var/lib/apt/lists/*

wget -O ecspresso.tar.gz "$ECSPRESSO_DOWNLOAD_URL"
tar zxvf ecspresso.tar.gz
mv ecspresso /usr/bin/ecspresso
chmod +x /usr/bin/ecspresso
wget -O jq "$JQ_DOWNLOAD_URL"
mv jq /usr/bin/jq
chmod +x /usr/bin/jq
wget -O yq "$YQ_DOWNLOAD_URL"
mv yq /usr/bin/yq
chmod +x /usr/bin/yq
wget -O "session-manager-plugin.deb" "$SESSION_MANAGER_PLUGIN_DOWNLOAD_URL"
dpkg -i session-manager-plugin.deb
