#!/bin/bash

# Base Android SDK path
export ANDROID_HOME=/workspaces/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# NDK paths (both versions)
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/21.1.6352462
export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME
export NDK_ROOT=$ANDROID_NDK_HOME

# Go path
export GOPATH=/home/codespace/go

# Build tools path
export ANDROID_BUILD_TOOLS=$ANDROID_HOME/build-tools/33.0.0

# Platform tools path
export ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools

# Update PATH to include all Android tools and Go
export PATH=$PATH:\
$GOPATH/bin:\
$ANDROID_HOME/cmdline-tools/latest/bin:\
$ANDROID_BUILD_TOOLS:\
$ANDROID_PLATFORM_TOOLS:\
$ANDROID_NDK_HOME:\
$ANDROID_HOME/tools/bin

# Create symlinks for NDK
if [ -d "$ANDROID_HOME/ndk/25.2.9519653" ]; then
    ln -sf $ANDROID_HOME/ndk/25.2.9519653 $ANDROID_HOME/ndk-bundle
fi

# Make sure directories exist
mkdir -p $ANDROID_HOME/licenses
