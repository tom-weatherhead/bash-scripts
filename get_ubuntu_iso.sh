#!/bin/bash

# See https://www.ubuntu.com/download/how-to-verify
# List of Ubuntu mirrors: https://launchpad.net/ubuntu/+cdmirrors

# Verify Ubuntu .iso download: (Write as a script? : 1) Replace 16.10 with $1 ; 2) Don't try to recv-keys if they are already present in the local keyring)

. bash_script_include.sh

ensure_presence_of_gpg_key()
{
	gpg --list-keys --with-fingerprint $2 || {
		gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys $1 || error_exit "gpg: Failed to receive key $1"
		gpg --list-keys --with-fingerprint $2 || error_exit "gpg: list-keys failed after recv-keys for key $1"
	}
}

MIRROR_URL_PREFIX="https://mirror.csclub.uwaterloo.ca/ubuntu-releases"
DISTRO_VERSION="16.10"

KEY_1_NAME="C598 6B4F 1257 FFA8 6632 CBA7 4618 1433 FBB7 5451"
KEY_1_FINGERPRINT="0xFBB75451"

KEY_2_NAME="8439 38DF 228D 22F7 B374 2BC0 D94A A3F0 EFE2 1092"
KEY_2_FINGERPRINT="0xEFE21092"

ensure_presence_of_gpg_key $KEY_1_NAME $KEY_1_FINGERPRINT
ensure_presence_of_gpg_key $KEY_2_NAME $KEY_2_FINGERPRINT
# gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys "8439 38DF 228D 22F7 B374 2BC0 D94A A3F0 EFE2 1092" "C598 6B4F 1257 FFA8 6632 CBA7 4618 1433 FBB7 5451"
# gpg --list-keys --with-fingerprint 0xEFE21092 0xFBB75451
#  - Our script shall check for keys by fingerprint one at a time, since "gpg --list-keys" returns an exit code of 0 (success) if any (not necessarily all) of the requested keys are found.

curl -O ${MIRROR_URL_PREFIX}/${DISTRO_VERSION}/SHA256SUMS || error_exit "curl: Failed to download SHA256SUMS"
curl -O ${MIRROR_URL_PREFIX}/${DISTRO_VERSION}/SHA256SUMS.gpg
gpg --verify SHA256SUMS.gpg SHA256SUMS
curl -O ${MIRROR_URL_PREFIX}/${DISTRO_VERSION}/ubuntu-${DISTRO_VERSION}-desktop-amd64.iso
sha256sum -c SHA256SUMS 2>&1 | grep OK
