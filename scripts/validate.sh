#!/bin/bash
set -ex

./gradlew clean build check test
