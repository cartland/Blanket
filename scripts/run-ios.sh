#!/bin/bash
set -ex

# Simulator details
BUNDLE_IDENTIFIER="com.chriscartland.blanket.Blanket"

# Find a running simulator
SIMULATOR_UDID=$(xcrun simctl list devices | grep -E 'Booted' | grep -E '(iPhone)' | sed -nE 's/.*\(([-0-9A-F]+)\).*$/\1/p' | head -n 1)

if [ -n "$SIMULATOR_UDID" ]; then
  echo "Found running simulator: ${SIMULATOR_UDID}"
else
  # Try to find iPhone 16 Pro (18.5)
  SIMULATOR_UDID=$(xcrun simctl list devices | grep "iPhone 16 Pro (18.5)" | sed -nE 's/.*\(([-0-9A-F]+)\).*$/\1/p' | head -n 1)
  if [ -n "$SIMULATOR_UDID" ]; then
    echo "No simulator running. Found iPhone 16 Pro (18.5): ${SIMULATOR_UDID}. Booting..."
    xcrun simctl boot "${SIMULATOR_UDID}"
    sleep 10 # Give the simulator time to boot
  else
    # If iPhone 16 Pro (18.5) not found, pick the highest version available iPhone simulator
    # Get all available iOS runtimes and sort them to find the highest version
    HIGHEST_OS_VERSION=$(xcrun simctl list runtimes | grep -E 'iOS' | sed -nE 's/.*iOS ([0-9.]+).*/\1/p' | sort -rV | head -n 1)

    if [ -z "$HIGHEST_OS_VERSION" ]; then
      echo "No iOS runtimes found. Please install one in Xcode."
      exit 1
    fi

    # Now find an iPhone simulator with this highest OS version
    SIMULATOR_UDID=$(xcrun simctl list devices | awk -v os_version="${HIGHEST_OS_VERSION}" 'BEGIN {found_os=0} /^-- iOS / {if ($3 == os_version) {found_os=1} else {found_os=0}} /iPhone/ {if (found_os==1) {match($0, /\(([-0-9A-F]+)\)/); print substr($0, RSTART+1, RLENGTH-2); exit}}' | head -n 1)

    if [ -z "$SIMULATOR_UDID" ]; then
      echo "No iPhone simulator found for iOS ${HIGHEST_OS_VERSION}. Please create one in Xcode."
      exit 1
    fi

    echo "No simulator running, iPhone 16 Pro (18.5) not found. Booting highest available iPhone simulator (iOS ${HIGHEST_OS_VERSION}): ${SIMULATOR_UDID}"
    xcrun simctl boot "${SIMULATOR_UDID}"
    sleep 10 # Give the simulator time to boot
  fi
fi

# 1. Build the iOS application
echo "Building iOS application..."
xcodebuild -sdk iphonesimulator -project iosApp/iosApp.xcodeproj -scheme iosApp -configuration Debug -derivedDataPath build/ios clean build

# 3. Uninstall the old application (if it exists)
echo "Uninstalling old application ${BUNDLE_IDENTIFIER} from simulator..."
xcrun simctl uninstall booted "${BUNDLE_IDENTIFIER}" || true # '|| true' to prevent script from exiting if app is not installed

# 4. Install the application
echo "Installing application ${BUNDLE_IDENTIFIER} on simulator..."
xcrun simctl install booted "build/ios/Build/Products/Debug-iphonesimulator/Blanket.app"

# 4. Launch the application
echo "Launching application ${BUNDLE_IDENTIFIER} on simulator..."
xcrun simctl launch booted "${BUNDLE_IDENTIFIER}"
