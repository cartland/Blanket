#!/bin/bash
set -ex

# Builds the debug iOS framework for the shared module.
./gradlew :shared:linkDebugFrameworkIosFat
