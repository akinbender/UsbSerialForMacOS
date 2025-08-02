# UsbSerialForMacOS


[![Build](https://github.com/akinbender/UsbSerialForMacOS/actions/workflows/build.yml/badge.svg)](https://github.com/akinbender/UsbSerialForMacOS/actions/workflows/build.yml)
[![NuGet](https://img.shields.io/nuget/v/UsbSerialForMacOS.svg?label=NuGet&logo=nuget)](https://www.nuget.org/packages/UsbSerialForMacOS/)

**UsbSerialForMacOS** is a .NET binding for a native Swift library that enables serial port communication on macOS and Mac Catalyst.  
It allows .NET MAUI and .NET 8+ apps to enumerate, open, read from, and write to serial devices (such as USB-to-serial adapters and 3D printers) using a simple C# API.

## Usage

1. Add the NuGet package to your .NET 8+ Mac or Mac Catalyst project.
2. Add following to Entitlements.plist

```xml
<key>com.apple.security.device.serial</key>
<true/>
```
3. Use the `UsbSerialManager` class to enumerate and communicate with serial devices.


```csharp
using UsbSerialForMacOS;

var manager = new UsbSerialManager();
var ports = manager.AvailablePorts();
if (ports.Length > 0)
{
    bool opened = manager.Open(ports[0], 115200);
    // Write/read as needed
    manager.Close();
}
```

**Version Support**

| Platform      | Target Framework      | Architectures         | Minimum macOS Version |
|-------------- |----------------------|-----------------------|-----------------------|
| macOS         | net8.0-macos         | x64, arm64             | 15.0+                 |
| Mac Catalyst  | net8.0-maccatalyst   | x64, arm64            | 18.0+                 |

> **.NET 8.0 or higher is required. Native libraries are included for both macOS and Mac Catalyst.**