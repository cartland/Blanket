#!/bin/bash
set -ex

# Framework name
FRAMEWORK_NAME="shared" # Assuming framework name matches module name

# Output paths for individual architecture frameworks
# Kotlin/Native usually places these under shared/build/bin/<targetName>/<buildType>Framework/
BUILD_DIR_ROOT="shared/build/bin"
IOS_ARM64_FRAMEWORK_PATH="${BUILD_DIR_ROOT}/iosArm64/debugFramework/${FRAMEWORK_NAME}.framework"
IOS_SIMULATOR_ARM64_FRAMEWORK_PATH="${BUILD_DIR_ROOT}/iosSimulatorArm64/debugFramework/${FRAMEWORK_NAME}.framework"
IOS_X64_FRAMEWORK_PATH="${BUILD_DIR_ROOT}/iosX64/debugFramework/${FRAMEWORK_NAME}.framework"

# Final output directory for the fat framework
# This is a chosen path for the combined artifact.
FAT_FRAMEWORK_DIR="shared/build/ios/debugFramework/${FRAMEWORK_NAME}.framework"

# Clean previous build
echo "Cleaning previous fat framework build..."
rm -rf "${FAT_FRAMEWORK_DIR}"
mkdir -p "${FAT_FRAMEWORK_DIR}/Modules" # Ensure Modules directory exists before copying into it

# Build frameworks for each architecture
echo "Building for iOS ARM64 (Device)..."
./gradlew :shared:linkDebugFrameworkIosArm64

echo "Building for iOS Simulator ARM64..."
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64

echo "Building for iOS X64 (Legacy Simulator)..."
./gradlew :shared:linkDebugFrameworkIosX64

# Create the directory for the fat framework if it wasn't fully created by rm -rf / mkdir -p
# This also handles the case where FRAMEWORK_NAME might have an extension if misinterpreted.
mkdir -p "${FAT_FRAMEWORK_DIR}"

# Combine the binaries using lipo
echo "Creating fat binary with lipo..."
lipo -create \
    "${IOS_ARM64_FRAMEWORK_PATH}/${FRAMEWORK_NAME}" \
    "${IOS_SIMULATOR_ARM64_FRAMEWORK_PATH}/${FRAMEWORK_NAME}" \
    "${IOS_X64_FRAMEWORK_PATH}/${FRAMEWORK_NAME}" \
    -output "${FAT_FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

# Copy other necessary files from one of the built frameworks (e.g., iosArm64, as it's a device build)
# Info.plist
echo "Copying Info.plist..."
cp "${IOS_ARM64_FRAMEWORK_PATH}/Info.plist" "${FAT_FRAMEWORK_DIR}/Info.plist"

# Modules: .swiftmodule files and potentially module.modulemap
# Note: Swift module files can sometimes be architecture-specific.
# A more robust solution might involve `xcodebuild -create-xcframework`,
# but for a basic fat framework, copying from one arch (e.g., arm64) often works.
echo "Copying Modules..."
# Ensure Modules subdirectory exists in FAT_FRAMEWORK_DIR
mkdir -p "${FAT_FRAMEWORK_DIR}/Modules"
# Copy all contents of the source swiftmodule directory
# This handles different file extensions like .swiftmodule, .swiftdoc, .abi.json etc.
cp -R "${IOS_ARM64_FRAMEWORK_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/"* "${FAT_FRAMEWORK_DIR}/Modules/"

# If a modulemap exists, copy it.
if [ -f "${IOS_ARM64_FRAMEWORK_PATH}/Modules/module.modulemap" ]; then
    echo "Copying module.modulemap..."
    cp "${IOS_ARM64_FRAMEWORK_PATH}/Modules/module.modulemap" "${FAT_FRAMEWORK_DIR}/Modules/module.modulemap"
fi

# Headers (if any)
if [ -d "${IOS_ARM64_FRAMEWORK_PATH}/Headers" ]; then
    echo "Copying Headers..."
    cp -R "${IOS_ARM64_FRAMEWORK_PATH}/Headers" "${FAT_FRAMEWORK_DIR}/"
fi

echo "Fat framework successfully created at ${FAT_FRAMEWORK_DIR}"
