#!/bin/zsh

set -e

# Clean previous builds
rm -rf build
rm -rf UsbSerialForMacOS.framework
rm -rf UsbSerialForMacOS.xcframework

# Build for macOS (x86_64)
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -arch x86_64 \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=build/macos/x86_64

# Build for Mac Catalyst (x86_64)
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=x86_64' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=build/maccatalyst/x86_64

# Create XCFramework
xcodebuild -create-xcframework \
  -framework build/macos/x86_64/UsbSerialForMacOS.framework \
  -framework build/maccatalyst/x86_64/UsbSerialForMacOS.framework \
  -output UsbSerialForMacOS.xcframework

echo "XCFramework created at UsbSerialForMacOS.xcframework"