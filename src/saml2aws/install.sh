#!/bin/bash
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
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

REPO=https://github.com/Versent/saml2aws
LATEST_SAML2AWS_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} ${REPO}/releases/latest) | sed -e 's/v//g')

if [ "${SAML2AWSVERSION}" = "latest" ]; then
    SAML2AWS_VERSION=$LATEST_SAML2AWS_VERSION
else
    SAML2AWS_VERSION="${SAML2AWSVERSION:-$LATEST_SAML2AWS_VERSION}"
fi
SAML2AWS_DOWNLOAD_URL=${REPO}/releases/download/v${SAML2AWS_VERSION}/saml2aws_${SAML2AWS_VERSION}_linux_${architecture}.tar.gz

wget -O saml2aws.tar.gz "$SAML2AWS_DOWNLOAD_URL"
tar zxvf saml2aws.tar.gz
mv saml2aws /usr/bin/saml2aws
chmod +x /usr/bin/saml2aws
rm saml2aws.tar.gz

if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

tee /usr/local/share/saml2aws-init.sh > /dev/null \
<< EOF
if [ "$USERNAME" != "root" ]; then
    mkdir -p /home/${USERNAME}/.aws
    ln -s /usr/local/share/.aws/config /home/${USERNAME}/.aws/config
    ln -s /usr/local/share/.saml2aws /home/${USERNAME}/.saml2aws
    touch /home/${USERNAME}/.aws/credentials
    chown -h "${USERNAME}" /home/${USERNAME}/.aws/credentials
    chmod +w /home/${USERNAME}/.aws/credentials
    mkdir /home/${USERNAME}/.aws/cli
    chown -R "${USERNAME}" /home/${USERNAME}/.aws/cli
else
    mkdir /root/.aws
    ln -s /usr/local/share/.aws/config /root/.aws/config
    ln -s /usr/local/share/.saml2aws /root/.saml2aws
    touch /root/.aws/credentials
    mkdir /root/.aws/cli
fi
EOF

chmod +x /usr/local/share/saml2aws-init.sh
