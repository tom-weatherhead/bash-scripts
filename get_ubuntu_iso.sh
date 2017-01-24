#!/bin/bash

See https://www.ubuntu.com/download/how-to-verify
List of Ubuntu mirrors: https://launchpad.net/ubuntu/+cdmirrors

- Verify Ubuntu .iso download: (Write as a script? : 1) Replace 16.10 with $1 ; 2) Don't try to recv-keys if they are already present in the local keyring)
  - gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys "8439 38DF 228D 22F7 B374 2BC0 D94A A3F0 EFE2 1092" "C598 6B4F 1257 FFA8 6632 CBA7 4618 1433 FBB7 5451"
  - gpg --list-keys --with-fingerprint 0xFBB75451 0xEFE21092
    - Our script shall check for keys by fingerprint one at a time, since "gpg --list-keys" returns an exit code of 0 (success) if any (not necessarily all) of the requested keys are found.
  - curl -O https://mirror.csclub.uwaterloo.ca/ubuntu-releases/16.10/SHA256SUMS
  - curl -O https://mirror.csclub.uwaterloo.ca/ubuntu-releases/16.10/SHA256SUMS.gpg
  - gpg --verify SHA256SUMS.gpg SHA256SUMS
  - curl -O https://mirror.csclub.uwaterloo.ca/ubuntu-releases/16.10/ubuntu-16.10-desktop-amd64.iso
  - sha256sum -c SHA256SUMS 2>&1 | grep OK
