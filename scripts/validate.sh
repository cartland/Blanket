#!/bin/bash
set -ex

# Cleans, builds, checks, and tests the entire project.
./gradlew clean build check test
