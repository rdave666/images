#!/bin/bash

# Update package lists
apt-get update

# Install required packages
apt-get install -y \
    golang \
    gradle \
    openjdk-11-jdk \
    wget \
    unzip

# Remove existing Go installation
rm -rf /usr/local/go

# Download and install Go
wget https://golang.org/dl/go1.17.6.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz
rm go1.17.6.linux-amd64.tar.gz

# Set up Go environment variables
export GOPATH=/home/codespace/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export GO111MODULE=on

# Clear any existing Go module cache
rm -rf $GOPATH/pkg/mod
rm -f /workspaces/images/go.mod
rm -f /workspaces/images/go.sum

# Create necessary directories
mkdir -p $GOPATH/bin

# Set up Go environment and tools
cd /workspaces/images
go mod init s3scanner
go clean -modcache
GOPROXY=direct go get golang.org/x/mobile@v0.0.0-20230301163155-e0f57694e12c
go install golang.org/x/mobile/cmd/gomobile@v0.0.0-20230301163155-e0f57694e12c

# Verify gomobile installation
if [ -f "$GOPATH/bin/gomobile" ]; then
    echo "Gomobile installed successfully"
    GOPATH=$GOPATH $GOPATH/bin/gomobile init
else
    echo "Error: Gomobile installation failed"
    exit 1
fi

# Create Android SDK directory
mkdir -p /workspaces/android-sdk
export ANDROID_HOME=/workspaces/android-sdk

# Download and install Command Line Tools
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-*_latest.zip
mkdir -p $ANDROID_HOME/cmdline-tools/latest
rsync -a cmdline-tools/ $ANDROID_HOME/cmdline-tools/latest/
rm -rf cmdline-tools commandlinetools-linux-*_latest.zip

# Set proper permissions
chown -R codespace:codespace $ANDROID_HOME

# Set up environment variables with absolute paths
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Set up Android SDK environment
source /workspaces/images/setup/android_env.sh

# Accept licenses and install required SDK packages
yes | sdkmanager --licenses
sdkmanager \
    "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.0" \
    "ndk;21.1.6352462" \
    "ndk;25.2.9519653"

# Create SDK licenses
echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$ANDROID_HOME/licenses/android-sdk-license"
echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> "$ANDROID_HOME/licenses/android-sdk-license"

# Verify NDK installation
if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "Error: NDK not found at $ANDROID_NDK_HOME"
    exit 1
fi

# Create persistent environment settings
cat /workspaces/images/setup/android_env.sh > /etc/profile.d/android-sdk.sh

# Source the new environment settings
source /etc/profile.d/android-sdk.sh

# Verify installations
echo "Verifying installations..."
if [ -f "$GOPATH/bin/gomobile" ]; then
    $GOPATH/bin/gomobile version
else
    echo "Error: Gomobile not found in $GOPATH/bin"
    exit 1
fi
go version
gradle -v
java -version
sdkmanager --list_installed

echo "Environment setup complete!"
