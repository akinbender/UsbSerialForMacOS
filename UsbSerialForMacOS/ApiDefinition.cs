using ObjCRuntime;
using Foundation;

namespace UsbSerialForMacOS;

[BaseType(typeof(NSObject))]
public interface UsbSerialManager
{
    [Export("openWithDevicePath:baudRate:")]
    bool Open(string devicePath, int baudRate);

    [Export("openDebugWithDevicePath:baudRate:")]
    string OpenDebug(string devicePath, int baudRate);

    [Export("writeWithData:")]
    int Write(NSData data);

    [Export("readWithMaxLength:")]
    NSData Read(int maxLength);

    [Export("writeDebugWithData:")]
    string WriteDebug(NSData data);
    
    [Export("readDebugWithMaxLength:")]
    string ReadDebug(int maxLength);

    [Export("close")]
    void Close();

    [Export("availablePorts")]
    string[] AvailablePorts();
}