#!/usr/bin/env bash
set -euo pipefail

: "${BUILD_CERTIFICATE_BASE64:?BUILD_CERTIFICATE_BASE64 is required}"
: "${P12_PASSWORD:?P12_PASSWORD is required}"
: "${BUILD_PROVISION_PROFILE_BASE64:?BUILD_PROVISION_PROFILE_BASE64 is required}"
: "${KEYCHAIN_PASSWORD:?KEYCHAIN_PASSWORD is required}"

CERTIFICATE_PATH="${RUNNER_TEMP}/build_certificate.p12"
PP_PATH="${RUNNER_TEMP}/build_pp.mobileprovision"
KEYCHAIN_PATH="${RUNNER_TEMP}/app-signing.keychain-db"

echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode > "$CERTIFICATE_PATH"
echo -n "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode > "$PP_PATH"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

security import "$CERTIFICATE_PATH" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security list-keychain -d user -s "$KEYCHAIN_PATH"

mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
PROFILE_UUID="$(/usr/libexec/PlistBuddy -c 'Print UUID' /dev/stdin <<< "$(security cms -D -i "$PP_PATH")")"
cp "$PP_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/${PROFILE_UUID}.mobileprovision"

PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print Name' /dev/stdin <<< "$(security cms -D -i "$PP_PATH")")"
echo "PROFILE_UUID=$PROFILE_UUID" >> "$GITHUB_ENV"
echo "PROVISIONING_PROFILE_NAME=$PROFILE_NAME" >> "$GITHUB_ENV"
