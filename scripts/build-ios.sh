#!/bin/bash
set -ex

FRAMEWORK_NAME="shared"
BUILD_TYPE="debug" # For Debug build

# Output paths for individual architecture frameworks from Kotlin Gradle plugin
KOTLIN_FRAMEWORKS_BUILD_DIR="shared/build/bin"
IOS_ARM64_FRAMEWORK_PATH="${KOTLIN_FRAMEWORKS_BUILD_DIR}/iosArm64/${BUILD_TYPE}Framework/${FRAMEWORK_NAME}.framework"
IOS_SIMULATOR_ARM64_FRAMEWORK_PATH="${KOTLIN_FRAMEWORKS_BUILD_DIR}/iosSimulatorArm64/${BUILD_TYPE}Framework/${FRAMEWORK_NAME}.framework"
IOS_X64_SIMULATOR_FRAMEWORK_PATH="${KOTLIN_FRAMEWORKS_BUILD_DIR}/iosX64/${BUILD_TYPE}Framework/${FRAMEWORK_NAME}.framework"

# Final output directory for the XCFramework
XCFRAMEWORK_OUTPUT_DIR="shared/build/XCFrameworks/${BUILD_TYPE}"
XCFRAMEWORK_PATH="${XCFRAMEWORK_OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"

# Clean previous XCFramework output
echo "Cleaning previous XCFramework output at ${XCFRAMEWORK_PATH}..."
rm -rf "${XCFRAMEWORK_PATH}"
mkdir -p "${XCFRAMEWORK_OUTPUT_DIR}" # Ensure the parent directory exists

# Build individual frameworks using Gradle
echo "Building ${FRAMEWORK_NAME} framework for iOS ARM64 (Device)..."
./gradlew :shared:linkDebugFrameworkIosArm64

echo "Building ${FRAMEWORK_NAME} framework for iOS Simulator ARM64..."
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64

echo "Building ${FRAMEWORK_NAME} framework for iOS X64 Simulator..."
./gradlew :shared:linkDebugFrameworkIosX64

# Create XCFramework using xcodebuild
echo "Creating ${FRAMEWORK_NAME}.xcframework..."
xcodebuild -create-xcframework \
    -framework "${IOS_ARM64_FRAMEWORK_PATH}" \
    -framework "${IOS_SIMULATOR_ARM64_FRAMEWORK_PATH}" \
    -framework "${IOS_X64_SIMULATOR_FRAMEWORK_PATH}" \
    -output "${XCFRAMEWORK_PATH}"

echo "XCFramework successfully created at ${XCFRAMEWORK_PATH}"
