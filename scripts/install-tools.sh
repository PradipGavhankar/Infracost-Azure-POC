#!/usr/bin/env bash
set -euo pipefail

TF_VERSION="${1:?Terraform version required}"
INFRACOST_VERSION="${2:?Infracost version required}"
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64) TF_ARCH="amd64"; INFRACOST_ARCH="amd64" ;;
  aarch64|arm64) TF_ARCH="arm64"; INFRACOST_ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 2 ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Install exact Terraform version; production organizations should additionally
# verify vendor checksums/signatures against their approved release manifest.
curl -fsSLo "$TMP/terraform.zip" \
  "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TF_ARCH}.zip"
unzip -oq "$TMP/terraform.zip" -d "$TMP/terraform"
sudo install -m 0755 "$TMP/terraform/terraform" /usr/local/bin/terraform

# Infracost v0.10.46 release asset.
curl -fsSLo "$TMP/infracost.tar.gz" \
  "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-${INFRACOST_ARCH}.tar.gz"
mkdir "$TMP/infracost"
tar -xzf "$TMP/infracost.tar.gz" -C "$TMP/infracost"
BIN="$(find "$TMP/infracost" -type f -name infracost -print -quit)"
test -n "$BIN"
sudo install -m 0755 "$BIN" /usr/local/bin/infracost

terraform version
infracost --version
