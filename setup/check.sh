#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_component() {
    local name=$1
    local command=$2
    echo -n "Checking $name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

# Directory checks
echo -e "\n${YELLOW}Checking directories:${NC}"
check_component "GOPATH" "[ -d \"$GOPATH\" ]"
check_component "Android SDK" "[ -d \"$ANDROID_HOME\" ]"
check_component "Android NDK" "[ -d \"$ANDROID_NDK_HOME\" ]"
check_component "Project directory" "[ -d \"/workspaces/images\" ]"

# Tool checks
echo -e "\n${YELLOW}Checking tools:${NC}"
check_component "Go" "go version"
check_component "Gomobile" "which gomobile"
check_component "Java" "java -version"
check_component "Gradle" "gradle -version"

# Project file checks
echo -e "\n${YELLOW}Checking project files:${NC}"
check_component "go.mod" "[ -f \"/workspaces/images/go.mod\" ]"
check_component "scanner.go" "[ -f \"/workspaces/images/s3scanner/scanner.go\" ]"

# Test build
echo -e "\n${YELLOW}Testing AAR build:${NC}"
cd /workspaces/images
if gomobile bind -target=android -androidapi 21 ./s3scanner; then
    echo -e "${GREEN}Build successful${NC}"
    if [ -f "s3scanner.aar" ]; then
        echo -e "${GREEN}AAR file generated${NC}"
        ls -lh s3scanner.aar
    fi
else
    echo -e "${RED}Build failed${NC}"
    exit 1
fi
