#!/bin/bash
set -ex

# Builds the iOS framework for the shared module.
./gradlew :shared:linkReleaseFrameworkIosFat
