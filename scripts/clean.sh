#!/bin/bash
set -ex

# Cleans the project by removing build artifacts.
# This is useful for ensuring a clean build.
./gradlew clean
