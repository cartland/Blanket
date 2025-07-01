#!/bin/bash
set -ex

# Checks the code formatting using Spotless.
# This script is used to verify that the code conforms to the project's style guide.
./gradlew spotlessCheck
