#!/bin/bash

echo "S3Scanner Environment Readiness Report" > environment_report.txt
echo "=====================================" >> environment_report.txt
echo "Generated: $(date)" >> environment_report.txt
echo "" >> environment_report.txt

# Check Go installation
echo "Go Environment:" >> environment_report.txt
if command -v go &> /dev/null; then
    echo "✓ Go $(go version | awk '{print $3}')" >> environment_report.txt
    echo "GOPATH: $GOPATH" >> environment_report.txt
else
    echo "✗ Go not found" >> environment_report.txt
    exit 1
fi

# Check Android SDK
echo -e "\nAndroid SDK:" >> environment_report.txt
if [ -d "$ANDROID_HOME" ]; then
    echo "✓ Android SDK found at: $ANDROID_HOME" >> environment_report.txt
    echo "Installed packages:" >> environment_report.txt
    sdkmanager --list_installed | grep -E "build-tools|platforms|ndk" >> environment_report.txt
else
    echo "✗ Android SDK not found" >> environment_report.txt
    exit 1
fi

# Check Java
echo -e "\nJava Environment:" >> environment_report.txt
if command -v java &> /dev/null; then
    echo "✓ $(java -version 2>&1 | head -n 1)" >> environment_report.txt
else
    echo "✗ Java not found" >> environment_report.txt
    exit 1
fi

# Check Gradle
echo -e "\nGradle:" >> environment_report.txt
if command -v gradle &> /dev/null; then
    echo "✓ $(gradle -version | grep Gradle)" >> environment_report.txt
else
    echo "✗ Gradle not found" >> environment_report.txt
    exit 1
fi

# Check Gomobile
echo -e "\nGomobile:" >> environment_report.txt
if command -v gomobile &> /dev/null; then
    echo "✓ Gomobile installed" >> environment_report.txt
    echo "Version: $(gomobile version 2>&1)" >> environment_report.txt
else
    echo "✗ Gomobile not found" >> environment_report.txt
    exit 1
fi

# Verify directory structure
echo -e "\nProject Structure:" >> environment_report.txt
PROJECT_ROOT="/workspaces/images"
for dir in "s3scanner" "android/app" "setup"; do
    if [ -d "$PROJECT_ROOT/$dir" ]; then
        echo "✓ $dir directory present" >> environment_report.txt
    else
        echo "✗ Missing directory: $dir" >> environment_report.txt
    fi
done

# Final status
echo -e "\nReadiness Status:" >> environment_report.txt
echo "Environment is ready for GitHub Integration phase" >> environment_report.txt
echo "You can proceed with building the S3Scanner Android application" >> environment_report.txt

cat environment_report.txt
echo "Report saved to environment_report.txt"
