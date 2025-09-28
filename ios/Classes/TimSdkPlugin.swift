import Flutter
import UIKit
import opentoy_ios

public class TimSdkPlugin: NSObject, FlutterPlugin, OpenToyCoreDelegate {
  private let openToyIOS = OpenToyIOS()
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tim_sdk", binaryMessenger: registrar.messenger())
    let instance = TimSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // 设置 OpenToyIOS 的代理
    instance.openToyIOS.delegate = instance
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    // 蓝牙相关方法
    case "initializeBluetooth":
      let bluetoothResult = openToyIOS.initializeBluetooth()
      switch bluetoothResult {
      case .success(let value):
        result(value)
      case .failure(let error):
        result(FlutterError(code: "BLUETOOTH_ERROR", message: error.localizedDescription, details: nil))
      }
    case "startScan":
      let scanResult = openToyIOS.startScan()
      switch scanResult {
      case .success(let value):
        result(value)
      case .failure(let error):
        result(FlutterError(code: "BLUETOOTH_ERROR", message: error.localizedDescription, details: nil))
      }
    case "stopScan":
      let stopResult = openToyIOS.stopScan()
      switch stopResult {
      case .success(let value):
        result(value)
      case .failure(let error):
        result(FlutterError(code: "BLUETOOTH_ERROR", message: error.localizedDescription, details: nil))
      }
    case "connectToDevice":
      if let args = call.arguments as? [String: Any],
         let deviceId = args["deviceId"] as? String {
        let connectResult = openToyIOS.connectToDevice(deviceId: deviceId)
        switch connectResult {
        case .success(let value):
          result(value)
        case .failure(let error):
          result(FlutterError(code: "BLUETOOTH_ERROR", message: error.localizedDescription, details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "deviceId is required", details: nil))
      }
    case "disconnectFromDevice":
      if let args = call.arguments as? [String: Any],
         let deviceId = args["deviceId"] as? String {
        let disconnectResult = openToyIOS.disconnectFromDevice(deviceId: deviceId)
        switch disconnectResult {
        case .success(let value):
          result(value)
        case .failure(let error):
          result(FlutterError(code: "BLUETOOTH_ERROR", message: error.localizedDescription, details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "deviceId is required", details: nil))
      }
    case "readBatteryLevel":
      if let args = call.arguments as? [String: Any],
         let deviceId = args["deviceId"] as? String {
        openToyIOS.readBatteryLevel(deviceId: deviceId) { batteryResult in
          switch batteryResult {
          case .success(let value):
            result(value)
          case .failure(let error):
            result(FlutterError(code: "BLUETOOTH_ERROR", message: error.localizedDescription, details: nil))
          }
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "deviceId is required", details: nil))
      }
    case "writeMotor":
      if let args = call.arguments as? [String: Any],
         let deviceId = args["deviceId"] as? String,
         let pwm = args["pwm"] as? [Int] {
        openToyIOS.writeMotor(deviceId: deviceId, pwm: pwm) { motorResult in
          switch motorResult {
          case .success(let value):
            result(value)
          case .failure(let error):
            result(FlutterError(code: "BLUETOOTH_ERROR", message: error.localizedDescription, details: nil))
          }
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "deviceId and pwm are required", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - OpenToyCoreDelegate
  public func bluetoothStateChanged(_ state: String) {
    // 可以在这里添加事件发送逻辑
    print("Bluetooth state changed: \(state)")
  }
  
  public func deviceDiscovered(_ device: [String: Any]) {
    print("Device discovered: \(device)")
  }
  
  public func deviceConnected(_ deviceId: String, deviceInfo: [String: Any]) {
    print("Device connected: \(deviceId), info: \(deviceInfo)")
  }
  
  public func deviceDisconnected(_ deviceId: String, error: String?) {
    print("Device disconnected: \(deviceId), error: \(error ?? "none")")
  }
  
  public func deviceConnectionFailed(_ deviceId: String, error: String?) {
    print("Device connection failed: \(deviceId), error: \(error ?? "none")")
  }
  
  public func characteristicValueUpdated(_ deviceId: String, characteristicId: String, data: [UInt8]) {
    print("Characteristic value updated: \(deviceId), \(characteristicId), data: \(data)")
  }
  
  public func characteristicReadFailed(_ deviceId: String, characteristicId: String, error: String) {
    print("Characteristic read failed: \(deviceId), \(characteristicId), error: \(error)")
  }
  
  public func characteristicWriteSuccess(_ deviceId: String, characteristicId: String) {
    print("Characteristic write success: \(deviceId), \(characteristicId)")
  }
  
  public func characteristicWriteFailed(_ deviceId: String, characteristicId: String, error: String) {
    print("Characteristic write failed: \(deviceId), \(characteristicId), error: \(error)")
  }
  
  public func servicesDiscoveryFailed(_ deviceId: String, error: String) {
    print("Services discovery failed: \(deviceId), error: \(error)")
  }
  
  public func characteristicsDiscoveryFailed(_ deviceId: String, serviceId: String, error: String) {
    print("Characteristics discovery failed: \(deviceId), \(serviceId), error: \(error)")
  }
}
