#!/bin/bash

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create output directory for reports
mkdir -p /workspaces/images/build_reports
REPORT_FILE="/workspaces/images/build_reports/aar_build_report.txt"
echo "S3Scanner AAR Build Report" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "----------------------------------------" >> $REPORT_FILE

# Verify environment
echo -e "\n${YELLOW}Verifying environment...${NC}"
echo "Environment Check:" >> $REPORT_FILE

source /workspaces/images/setup/android_env.sh

if [ -z "$ANDROID_HOME" ] || [ -z "$ANDROID_NDK_HOME" ] || [ -z "$GOPATH" ]; then
    echo "Environment variables for Android SDK, NDK, or Go are not set."
    exit 1
fi

echo "Android SDK, NDK, and Go environment variables are set correctly."

# Check NDK
if [ -d "$ANDROID_NDK_HOME" ]; then
    echo -e "${GREEN}✓ NDK found at $ANDROID_NDK_HOME${NC}"
    echo "✓ NDK found at $ANDROID_NDK_HOME" >> $REPORT_FILE
else
    echo -e "${RED}✗ NDK not found${NC}"
    echo "✗ NDK not found" >> $REPORT_FILE
    exit 1
fi

# Build AAR
echo -e "\n${YELLOW}Building AAR...${NC}"
echo -e "\nBuild Process:" >> $REPORT_FILE
cd /workspaces/images
BUILD_OUTPUT=$(gomobile bind -v -target=android -androidapi 21 ./s3scanner 2>&1)
BUILD_STATUS=$?

echo "$BUILD_OUTPUT" >> $REPORT_FILE

# Verify AAR file
if [ $BUILD_STATUS -eq 0 ] && [ -f "s3scanner.aar" ]; then
    AAR_SIZE=$(ls -lh s3scanner.aar | awk '{print $5}')
    echo -e "${GREEN}✓ AAR generated successfully${NC}"
    echo -e "${GREEN}✓ Size: $AAR_SIZE${NC}"
    echo "✓ AAR generated successfully" >> $REPORT_FILE
    echo "✓ Size: $AAR_SIZE" >> $REPORT_FILE
    
    # Create build success marker
    echo "Build completed successfully at $(date)" > /workspaces/images/build_reports/build_success
else
    echo -e "${RED}✗ AAR generation failed${NC}"
    echo "✗ AAR generation failed" >> $REPORT_FILE
    echo "Error output:" >> $REPORT_FILE
    echo "$BUILD_OUTPUT" >> $REPORT_FILE
    exit 1
fi

# Summary
echo -e "\n${YELLOW}Build Report Summary:${NC}"
echo -e "- Report location: ${GREEN}$REPORT_FILE${NC}"
echo -e "- AAR location: ${GREEN}/workspaces/images/s3scanner.aar${NC}"
echo -e "- Build status: ${GREEN}Success${NC}"
echo -e "- AAR size: ${GREEN}$AAR_SIZE${NC}"

echo -e "\n${GREEN}Project is ready for Android App Integration${NC}"
