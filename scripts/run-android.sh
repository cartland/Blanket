#!/bin/bash
set -ex

./gradlew :composeApp:installDebug
adb shell am start -n com.chriscartland.blanket/.MainActivity
