#!/bin/zsh

set -e

# Clean previous builds
envdir=build/dylib
rm -rf $envdir
mkdir -p $envdir/arm64 $envdir/x86_64 $envdir/universal

# Build for Mac Catalyst x86_64 as .dylib
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=x86_64' \
  MACH_O_TYPE=mh_dylib \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=$envdir/x86_64/maccatalyst

# Build for macOS x86_64 as .dylib
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -arch x86_64 \
  MACH_O_TYPE=mh_dylib \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=$envdir/x86_64/macos

# Combine into universal .dylib
xcodebuild -create-xcframework \
  -library $envdir/x86_64/macos/libUsbSerialForMacOS.dylib \
  -library $envdir/x86_64/maccatalyst/libUsbSerialForMacOS.dylib \
  -output UsbSerialForMacOS.xcframework

echo "Universal .dylib created at UsbSerialForMacOS.dylib"
