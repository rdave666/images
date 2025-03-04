#!/bin/bash

set -e

ANDROID_SDK_ROOT="/workspaces/android-sdk"
CMDLINE_TOOLS_PATH="$ANDROID_SDK_ROOT/cmdline-tools"
CMDLINE_TOOLS_VERSION="11076708" # Latest stable version

# Check common SDK locations
POSSIBLE_SDK_PATHS=(
    "/usr/local/lib/android/sdk"
    "/usr/lib/android-sdk"
    "$HOME/Android/Sdk"
    "$HOME/Library/Android/sdk"
)

# Function to check if path contains valid SDK
check_sdk_path() {
    local path=$1
    if [ -d "$path" ] && [ -d "$path/platform-tools" ]; then
        echo "Found existing SDK at: $path"
        return 0
    fi
    return 1
}

# Check for existing SDK installation
for sdk_path in "${POSSIBLE_SDK_PATHS[@]}"; do
    if check_sdk_path "$sdk_path"; then
        # Create symbolic links for required directories
        mkdir -p "$ANDROID_SDK_ROOT"
        for dir in platform-tools platforms build-tools ndk cmdline-tools; do
            if [ -d "$sdk_path/$dir" ] && [ ! -d "$ANDROID_SDK_ROOT/$dir" ]; then
                ln -sf "$sdk_path/$dir" "$ANDROID_SDK_ROOT/$dir"
                echo "Linked $dir from existing SDK"
            fi
        done
        export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
        export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
        echo "Using existing SDK via symbolic links"
        exit 0
    fi
done

# If no existing SDK found, proceed with download and installation
echo "No existing SDK found, downloading..."

# Download command-line tools if not present
if [ ! -f "commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip" ]; then
    wget "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
fi

# Create directories
mkdir -p "$CMDLINE_TOOLS_PATH/latest"

# Extract new command-line tools
unzip -qo "commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"

# Move tools to correct location
cp -r cmdline-tools/* "$CMDLINE_TOOLS_PATH/latest/"

# Set permissions
chmod -R +x "$CMDLINE_TOOLS_PATH/latest/bin"

# Export environment variables
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export PATH="$CMDLINE_TOOLS_PATH/latest/bin:$PATH"

# Accept licenses
yes | "$CMDLINE_TOOLS_PATH/latest/bin/sdkmanager" --licenses

# Clean up any existing NDK installations
rm -rf "$ANDROID_SDK_ROOT/ndk-bundle"
rm -rf "$ANDROID_SDK_ROOT/ndk"

# Install required SDK packages including NDK (changing NDK version)
"$CMDLINE_TOOLS_PATH/latest/bin/sdkmanager" \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "ndk;23.1.7779620"  # Changed to a version supporting API levels 19-33

# Verify NDK installation
if [ ! -d "$ANDROID_SDK_ROOT/ndk/23.1.7779620" ]; then
    log_error "NDK installation failed"
    exit 1
fi

# Set up environment variables
export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/23.1.7779620"
export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"

# Create compatibility symlink
ln -sf "$ANDROID_NDK_HOME" "$ANDROID_SDK_ROOT/ndk-bundle"

# Add to environment
echo "export ANDROID_NDK_HOME=$ANDROID_NDK_HOME" >> ~/.bashrc
echo "export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME" >> ~/.bashrc

# Cleanup
rm -rf cmdline-tools
rm -f "commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"

source /workspaces/images/setup/android_env.sh
