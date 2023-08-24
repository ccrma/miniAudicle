#!/bin/sh

echo xcrun notarytool submit "$1" \
    --team-id "$NOTARIZATION_TEAM_ID" \
    --apple-id "$NOTARIZATION_USERNAME" \
    --password "****" \
    --wait

xcrun notarytool submit "$1" \
    --team-id "$NOTARIZATION_TEAM_ID" \
    --apple-id "$NOTARIZATION_USERNAME" \
    --password "$NOTARIZATION_PASSWORD" \
    --wait
