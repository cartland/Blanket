#!/bin/bash
set -ex

# Builds the debug XCFramework for the shared module.
echo "Building shared Debug XCFramework..."
./gradlew :shared:assembleSharedDebugXCFramework

echo "XCFramework build complete."
echo "Output typically found in shared/build/XCFrameworks/debug/"
