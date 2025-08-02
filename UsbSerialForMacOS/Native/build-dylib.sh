#!/bin/zsh

set -e

# Clean previous builds
envdir=build/dylib
rm -rf build
rm -rf UsbSerialForMacOS.framework
rm -rf UsbSerialForMacOS.xcframework
mkdir -p $envdir/macos/arm64 $envdir/macos/x86_64 $envdir/macos/universal
mkdir -p $envdir/maccatalyst/arm64 $envdir/maccatalyst/x86_64 $envdir/maccatalyst/universal

# Build for macOS arm64 as .dylib
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -arch arm64 \
  MACH_O_TYPE=mh_dylib \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=$envdir/macos/arm64

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

# Combine into universal macOS .dylib
lipo -create \
  $envdir/macos/arm64/libUsbSerialForMacOS.dylib \
  $envdir/macos/x86_64/libUsbSerialForMacOS.dylib \
  -output $envdir/macos/UsbSerialForMacOS.dylib

# Build for Mac Catalyst arm64 as .dylib
xcodebuild -scheme UsbSerialForMacOS \
  -sdk macosx \
  -configuration Release \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  MACH_O_TYPE=mh_dylib \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build \
  CONFIGURATION_BUILD_DIR=$envdir/maccatalyst/arm64

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

# Combine into universal Mac Catalyst .dylib
lipo -create \
  $envdir/maccatalyst/arm64/UsbSerialForMacOS.dylib \
  $envdir/maccatalyst/x86_64/UsbSerialForMacOS.dylib \
  -output $envdir/maccatalyst/UsbSerialForMacOS.dylib

xcodebuild -create-xcframework \
  -library build/dylib/macos/UsbSerialForMacOS.dylib \
  -library build/dylib/maccatalyst/UsbSerialForMacOS.dylib \
  -output UsbSerialForMacOS.xcframework

codesign --force --sign - --deep UsbSerialForMacOS.xcframework

echo "Universal .dylib created at:"
echo "  $envdir/macos/universal/UsbSerialForMacOS.dylib (macOS)"
echo "  $envdir/maccatalyst/universal/UsbSerialForMacOS.dylib (Mac Catalyst)"
