#!/bin/bash

set -e

# Clean up any existing installation
go clean -modcache

# Install gomobile using specific version
GOMOBILE_VERSION="v0.0.0-20230922142353-e2f452493d57"
go mod download golang.org/x/mobile@$GOMOBILE_VERSION
go get golang.org/x/mobile/cmd/gomobile@$GOMOBILE_VERSION

# Ensure GOPATH is set and exported
GOPATH=$(go env GOPATH)
export GOPATH
export PATH="$GOPATH/bin:$PATH"

# Source Android environment variables
source /workspaces/images/setup/android_env.sh

# Verify installation
if [ ! -f "$GOPATH/bin/gomobile" ]; then
    echo "Failed to install gomobile"
    exit 1
fi

# Initialize gomobile
"$GOPATH/bin/gomobile" init

# Print version and environment info
echo "Environment:"
echo "GOPATH: $GOPATH"
echo "PATH: $PATH"
echo "ANDROID_NDK_HOME: $ANDROID_NDK_HOME"
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
