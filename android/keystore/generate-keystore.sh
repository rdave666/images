#!/bin/bash

if [ -z "$KEYSTORE_PASSWORD" ] || [ -z "$KEY_ALIAS" ] || [ -z "$KEY_PASSWORD" ]; then
    echo "Error: Required environment variables not set"
    echo "Please set: KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD"
    exit 1
fi

keytool -genkeypair \
    -keystore release.keystore \
    -alias $KEY_ALIAS \
    -keyalg RSA \
    -keysize 2048 \
    -validity 9125 \
    -storepass $KEYSTORE_PASSWORD \
    -keypass $KEY_PASSWORD \
    -dname "CN=S3Scanner,O=S3Scanner,L=Unknown,C=US"
