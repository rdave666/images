#!/usr/bin/env bash
set -e

# Feature options (populated by devcontainer at build time)
INSTALL_BUILD_TOOLS=${INSTALL_BUILD_TOOLS:-"true"}
INSTALL_PLATFORM_TOOLS=${INSTALL_PLATFORM_TOOLS:-"true"}
SDK_VERSION=${SDK_VERSION:-"latest"}

# Where you want to install the SDK
ANDROID_SDK_ROOT="/usr/local/android-sdk"
CMDLINE_TOOLS_PATH="$ANDROID_SDK_ROOT/cmdline-tools"

echo "**** Installing dependencies for Android SDK ****"
apt-get update -y
# You can add other packages you need (unzip, curl, Java, etc.)
apt-get install -y --no-install-recommends \
    unzip \
    wget \
    ca-certificates \
    openjdk-11-jdk

echo "**** Downloading Android cmdline-tools (version: $SDK_VERSION) ****"
mkdir -p "$CMDLINE_TOOLS_PATH"
cd "$CMDLINE_TOOLS_PATH"

# For a specific version, you can replace $SDK_VERSION with e.g. "9477386_latest"
if [ "$SDK_VERSION" = "latest" ]; then
    SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
else
    # Or dynamically build the URL if you want to handle custom versions
    SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-${SDK_VERSION}.zip"
fi

wget -qO cmdline-tools.zip "$SDK_URL"
unzip -q cmdline-tools.zip
rm cmdline-tools.zip

# The folder name might be "cmdline-tools" or "cmdline-tools/latest" after unzipping.
# Let's rename it to "latest" so that sdkmanager can find it:
mv cmdline-tools latest

echo "**** Setting up environment variables ****"
# These lines will ensure that future shells know where ANDROID_SDK_ROOT is
echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> /etc/bash.bashrc
echo "export PATH=\$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools" >> /etc/bash.bashrc

# For the current shell:
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"

echo "**** Accepting SDK licenses ****"
yes | sdkmanager --licenses || true

if [ "$INSTALL_PLATFORM_TOOLS" = "true" ]; then
    echo "**** Installing platform-tools ****"
    sdkmanager "platform-tools"
fi

if [ "$INSTALL_BUILD_TOOLS" = "true" ]; then
    echo "**** Installing build-tools (latest) ****"
    # You could specify a version like "build-tools;33.0.0"
    sdkmanager "build-tools;33.0.0" || true
fi

echo "**** Android SDK installation complete! ****"
