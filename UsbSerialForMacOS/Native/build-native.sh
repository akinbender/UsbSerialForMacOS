#!/bin/zsh

set -e

# Clean previous builds
rm -rf build
rm -rf UsbSerialForMacOS.framework
rm -rf UsbSerialForMacOS.xcframework

# Build for macOS (arm64)
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -arch arm64 \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=build/macos/arm64

# Build for macOS (x86_64)
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -arch x86_64 \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=build/macos/x86_64

# Build for Mac Catalyst (arm64)
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=build/maccatalyst/arm64

# Build for Mac Catalyst (x86_64)
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=x86_64' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=build/maccatalyst/x86_64

# Combine macOS arm64 and x86_64 into a universal ("fat") framework
FAT_MACOS_DIR=build/macos/universal
mkdir -p $FAT_MACOS_DIR
cp -R build/macos/arm64/UsbSerialForMacOS.framework $FAT_MACOS_DIR

lipo -create \
  build/macos/arm64/UsbSerialForMacOS.framework/UsbSerialForMacOS \
  build/macos/x86_64/UsbSerialForMacOS.framework/UsbSerialForMacOS \
  -output $FAT_MACOS_DIR/UsbSerialForMacOS.framework/UsbSerialForMacOS

FAT_MACCATALYST_DIR=build/maccatalyst/universal
mkdir -p $FAT_MACCATALYST_DIR
cp -R build/maccatalyst/arm64/UsbSerialForMacOS.framework $FAT_MACCATALYST_DIR

lipo -create \
  build/maccatalyst/arm64/UsbSerialForMacOS.framework/UsbSerialForMacOS \
  build/maccatalyst/x86_64/UsbSerialForMacOS.framework/UsbSerialForMacOS \
  -output $FAT_MACCATALYST_DIR/UsbSerialForMacOS.framework/UsbSerialForMacOS

# Create XCFramework
xcodebuild -create-xcframework \
  -framework build/macos/universal/UsbSerialForMacOS.framework \
  -framework build/maccatalyst/universal/UsbSerialForMacOS.framework \
  -output UsbSerialForMacOS.xcframework

echo "XCFramework created at UsbSerialForMacOS.xcframework"