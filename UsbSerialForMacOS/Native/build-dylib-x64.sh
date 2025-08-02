#!/bin/zsh

set -e

# Clean previous builds
envdir=build/dylib
rm -rf build
rm -rf UsbSerialForMacOS.framework
rm -rf UsbSerialForMacOS.xcframework

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
  CONFIGURATION_BUILD_DIR=$envdir/maccatalyst/x86_64

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
  CONFIGURATION_BUILD_DIR=$envdir/macos/x86_64

# Combine into universal .dylib
xcodebuild -create-xcframework \
  -library $envdir/macos/x86_64/libUsbSerialForMacOS.dylib \
  -library $envdir/maccatalyst/x86_64/libUsbSerialForMacOS.dylib \
  -output UsbSerialForMacOS.xcframework

echo "Universal .dylib created at UsbSerialForMacOS.dylib"
