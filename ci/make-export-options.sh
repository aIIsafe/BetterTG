#!/usr/bin/env bash
set -euo pipefail

: "${APPLE_TEAM_ID:?APPLE_TEAM_ID is required}"
: "${PRODUCT_BUNDLE_IDENTIFIER:?PRODUCT_BUNDLE_IDENTIFIER is required}"
: "${PROVISIONING_PROFILE_NAME:?PROVISIONING_PROFILE_NAME is required}"

cat > ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${APPLE_TEAM_ID}</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>${PRODUCT_BUNDLE_IDENTIFIER}</key>
        <string>${PROVISIONING_PROFILE_NAME}</string>
    </dict>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
