#!/bin/bash
set -ex

# Builds the iOS application.
# This script creates the Xcode framework for the iOS application.
./gradlew :shared:linkDebugFrameworkIosFat