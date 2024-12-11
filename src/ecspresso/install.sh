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

architecture="$(uname -m)"
case ${architecture} in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    aarch32 | armv7* | armvhf*) architecture="arm";;
    i?86) architecture="386";;
    *) echo "(!) Architecture ${architecture} unsupported"; exit 1 ;;
esac

apt update && \
apt install -y ca-certificates curl wget && \
rm -rf /var/lib/apt/lists/*

REPO=https://github.com/kayac/ecspresso
LATEST_ECSPRESSO_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} ${REPO}/releases/latest) | sed -e 's/v//g')

if [ "${ECSPRESSOVERSION}" = "latest" ]; then
    ECSPRESSO_VERSION=$LATEST_ECSPRESSO_VERSION
else
    ECSPRESSO_VERSION="${ECSPRESSOVERSION:-$LATEST_ECSPRESSO_VERSION}"
fi
ECSPRESSO_DOWNLOAD_URL=${REPO}/releases/download/v${ECSPRESSO_VERSION}/ecspresso_${ECSPRESSO_VERSION}_linux_${architecture}.tar.gz

USE_SESSION_MANAGER_PLUGIN="${USESESSIONMANAGERPLUGIN:-"false"}"
JQ_VERSION="${JQVERSION:-"none"}"
YQ_VERSION="${YQVERSION:-"none"}"

wget -O ecspresso.tar.gz "$ECSPRESSO_DOWNLOAD_URL"
tar zxvf ecspresso.tar.gz
mv ecspresso /usr/bin/ecspresso
chmod +x /usr/bin/ecspresso

if [ "${USE_SESSION_MANAGER_PLUGIN}" = "true" ]; then
    if [ "${architecture}" = "arm64" ]; then SM_ARCH=arm64; else SM_ARCH=64bit; fi
    SESSION_MANAGER_PLUGIN_DOWNLOAD_URL=https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${SM_ARCH}/session-manager-plugin.deb
    wget -O "session-manager-plugin.deb" "$SESSION_MANAGER_PLUGIN_DOWNLOAD_URL"
    dpkg -i session-manager-plugin.deb
fi

if [ "${JQ_VERSION}" != "none" ]; then
    if [ "${JQ_VERSION}" = "latest" ]; then
        JQ_DOWNLOAD_URL=https://github.com/stedolan/jq/releases/${JQ_VERSION}/download/jq-linux64
    else
        JQ_DOWNLOAD_URL=https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux64
    fi
    wget -O jq "$JQ_DOWNLOAD_URL"
    mv jq /usr/bin/jq
    chmod +x /usr/bin/jq
fi

if [ "${YQ_VERSION}" != "none" ]; then
    if [ "${YQ_VERSION}" = "latest" ]; then
        YQ_DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/${YQ_VERSION}/download/yq_linux_${architecture}
    else
        YQ_DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${architecture}
    fi
    wget -O yq "$YQ_DOWNLOAD_URL"
    mv yq /usr/bin/yq
    chmod +x /usr/bin/yq
fi
