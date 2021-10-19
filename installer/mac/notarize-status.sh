#!/bin/sh

xcrun altool --notarization-info "$1" --username "$NOTARIZATION_USERNAME" --password "$NOTARIZATION_PASSWORD"

