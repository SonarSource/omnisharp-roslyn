#!/bin/bash
# PGP-sign each omnisharp zip/tar.gz archive, producing .asc files.
# Uses GPG_SIGNING_KEY and GPG_SIGNING_PASSPHRASE from env.
set -e

if [ -z "$GPG_SIGNING_KEY" ] || [ -z "$GPG_SIGNING_PASSPHRASE" ]; then
  echo "Error: GPG_SIGNING_KEY and GPG_SIGNING_PASSPHRASE must be set"
  exit 1
fi

GNUPGHOME=$(mktemp -d)
trap "rm -rf ${GNUPGHOME}" EXIT
export GNUPGHOME

echo "Importing GPG key..."
echo "${GPG_SIGNING_PASSPHRASE}" | gpg --batch --pinentry-mode loopback --passphrase-fd 0 --quiet --import <(echo "${GPG_SIGNING_KEY}")

echo "Signing artifacts..."
for artifact in $(find artifacts/package -type f \( -name "omnisharp-*.zip" -o -name "omnisharp-*.tar.gz" \) 2>/dev/null); do
  [ -f "$artifact" ] || continue
  echo "Signing: $artifact"
  echo "${GPG_SIGNING_PASSPHRASE}" | gpg --batch --pinentry-mode loopback --passphrase-fd 0 --quiet --detach-sign --armor "$artifact"
  echo "  -> ${artifact}.asc"
done

echo "PGP signing complete."
