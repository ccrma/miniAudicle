#!/bin/sh

echo xcrun altool --notarize-app \
    --primary-bundle-id "$NOTARIZATION_PRIMARY_BUNDLE_ID" \
    --username "$NOTARIZATION_USERNAME" \
    --password "$NOTARIZATION_PASSWORD" \
    --file "$1"

xcrun altool --notarize-app \
    --primary-bundle-id "$NOTARIZATION_PRIMARY_BUNDLE_ID" \
    --username "$NOTARIZATION_USERNAME" \
    --password "$NOTARIZATION_PASSWORD" \
    --file "$1"
