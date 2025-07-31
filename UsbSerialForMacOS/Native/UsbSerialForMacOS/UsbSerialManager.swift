import Foundation
import IOKit.serial

@objc(UsbSerialManager)
public class UsbSerialManager: NSObject {
    private var serialPort: Int32 = -1
    
    @objc public func availablePorts() -> [String] {
        let fileManager = FileManager.default
        let devContents = try? fileManager.contentsOfDirectory(atPath: "/dev")
        let ports = devContents?.filter { $0.hasPrefix("tty.") || $0.hasPrefix("cu.") } ?? []
        return ports.map { "/dev/" + $0 }
    }

    @objc public func open(devicePath: String, baudRate: Int32) -> Bool {
        // Use Darwin.open to disambiguate from the instance method
        serialPort = Darwin.open(devicePath, O_RDWR | O_NOCTTY | O_NONBLOCK)
        guard serialPort != -1 else {
            print("Failed to open \(devicePath), errno: \(errno)")
            return false
        }

        var settings = termios()
        tcgetattr(serialPort, &settings)
        cfmakeraw(&settings)
        cfsetspeed(&settings, speed_t(baudRate))
        tcsetattr(serialPort, TCSANOW, &settings)
        
        return true
    }

    @objc public func openDebug(devicePath: String, baudRate: Int32) -> String {
        var debugLog = ""
        serialPort = Darwin.open(devicePath, O_RDWR | O_NOCTTY | O_NONBLOCK)
        if serialPort == -1 {
            debugLog += "Failed to open \(devicePath), errno: \(errno)"
            return debugLog
        } else {
            debugLog += "Opened \(devicePath) successfully.\n"
        }

        var settings = termios()
        if tcgetattr(serialPort, &settings) != 0 {
            debugLog += "tcgetattr failed, errno: \(errno)\n"
        }
        cfmakeraw(&settings)
        if cfsetspeed(&settings, speed_t(baudRate)) != 0 {
            debugLog += "cfsetspeed failed, errno: \(errno)\n"
        }
        if tcsetattr(serialPort, TCSANOW, &settings) != 0 {
            debugLog += "tcsetattr failed, errno: \(errno)\n"
        }
        debugLog += "Port configured for baud \(baudRate).\n"
        return debugLog
    }
    
    @objc public func write(data: Data) -> Int32 {
        return data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Int32 in
            guard let baseAddress = bytes.baseAddress else { return -1 }
            let bytesWritten = Darwin.write(serialPort, baseAddress, data.count)
            return Int32(bytesWritten) // Explicitly convert Int to Int32
        }
    }
    
    @objc public func writeDebug(data: Data) -> String {
        let result = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Int32 in
            guard let baseAddress = bytes.baseAddress else { return -1 }
            return Int32(Darwin.write(serialPort, baseAddress, data.count))
        }
        if result < 0 {
            return "Write failed, errno: \(errno)"
        } else {
            return "Wrote \(result) bytes"
        }
    }

    @objc public func read(maxLength: Int32) -> Data {
        var length = Int(maxLength);
        if length <= 0 {
            length = 1024
        }
        var buffer = [UInt8](repeating: 0, count: length)
        let bytesRead = Darwin.read(serialPort, &buffer, length)
        return Data(bytes: buffer, count: bytesRead > 0 ? bytesRead : 0)
    }

    @objc public func readDebug(maxLength: Int) -> String {
        if serialPort == -1 {
            return "Serial port not open"
        }
        var length = Int(maxLength);
        if length <= 0 {
            length = 1024
        }
        var buffer = [UInt8](repeating: 0, count: length)
        let bytesRead = Darwin.read(serialPort, &buffer, length)
        if bytesRead < 0 {
            return "Read failed, errno: \(errno), fd: \(serialPort), maxLength: \(maxLength)"
        } else if bytesRead == 0 {
            return "No data available"
        } else {
            let data = Data(bytes: buffer, count: bytesRead)
            if let str = String(data: data, encoding: .utf8) {
                return "Read \(bytesRead) bytes: \(str)"
            } else {
                return "Read \(bytesRead) bytes: \(data.map { String(format: "%02x", $0) }.joined(separator: " "))"
            }
        }
    }

    @objc public func close() {
        if serialPort != -1 {
            Darwin.close(serialPort)
            serialPort = -1
        }
    }
}
