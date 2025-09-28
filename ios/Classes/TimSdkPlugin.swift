import Flutter
import UIKit
import opentoy_ios

public class TimSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, OpenToyCoreDelegate {
  private let openToyIOS = OpenToyIOS()
  private var eventSink: FlutterEventSink?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tim_sdk", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "tim_sdk/events", binaryMessenger: registrar.messenger())
    let instance = TimSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
    
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
  
  // MARK: - FlutterStreamHandler
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
  
  // MARK: - OpenToyCoreDelegate
  public func bluetoothStateChanged(_ state: String) {
    print("Bluetooth state changed: \(state)")
    
    // 发送蓝牙状态变化事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "bluetoothStateChanged",
        "state": state
      ]
      eventSink(eventData)
    }
  }
  
  public func deviceDiscovered(_ device: [String: Any]) {
    print("Device discovered: \(device)")
    
    // 发送设备发现事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "deviceDiscovered",
        "device": device
      ]
      eventSink(eventData)
    }
  }
  
  public func deviceConnected(_ deviceId: String, deviceInfo: [String: Any]) {
    print("Device connected: \(deviceId), info: \(deviceInfo)")
    
    // 发送设备连接事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "deviceConnected",
        "deviceId": deviceId,
        "deviceInfo": deviceInfo
      ]
      eventSink(eventData)
    }
  }
  
  public func deviceDisconnected(_ deviceId: String, error: String?) {
    print("Device disconnected: \(deviceId), error: \(error ?? "none")")
    
    // 发送设备断开事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "deviceDisconnected",
        "deviceId": deviceId,
        "error": error ?? ""
      ]
      eventSink(eventData)
    }
  }
  
  public func deviceConnectionFailed(_ deviceId: String, error: String?) {
    print("Device connection failed: \(deviceId), error: \(error ?? "none")")
    
    // 发送设备连接失败事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "deviceConnectionFailed",
        "deviceId": deviceId,
        "error": error ?? ""
      ]
      eventSink(eventData)
    }
  }
  
  public func characteristicValueUpdated(_ deviceId: String, characteristicId: String, data: [UInt8]) {
    print("Characteristic value updated: \(deviceId), \(characteristicId), data: \(data)")
    
    // 发送特征值更新事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "characteristicValueUpdated",
        "deviceId": deviceId,
        "characteristicId": characteristicId,
        "data": data.map { Int($0) } // 转换为 Int 数组
      ]
      eventSink(eventData)
    }
  }
  
  public func characteristicReadFailed(_ deviceId: String, characteristicId: String, error: String) {
    print("Characteristic read failed: \(deviceId), \(characteristicId), error: \(error)")
    
    // 发送特征值读取失败事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "characteristicReadFailed",
        "deviceId": deviceId,
        "characteristicId": characteristicId,
        "error": error
      ]
      eventSink(eventData)
    }
  }
  
  public func characteristicWriteSuccess(_ deviceId: String, characteristicId: String) {
    print("Characteristic write success: \(deviceId), \(characteristicId)")
    
    // 发送特征值写入成功事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "characteristicWriteSuccess",
        "deviceId": deviceId,
        "characteristicId": characteristicId
      ]
      eventSink(eventData)
    }
  }
  
  public func characteristicWriteFailed(_ deviceId: String, characteristicId: String, error: String) {
    print("Characteristic write failed: \(deviceId), \(characteristicId), error: \(error)")
    
    // 发送特征值写入失败事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "characteristicWriteFailed",
        "deviceId": deviceId,
        "characteristicId": characteristicId,
        "error": error
      ]
      eventSink(eventData)
    }
  }
  
  public func servicesDiscoveryFailed(_ deviceId: String, error: String) {
    print("Services discovery failed: \(deviceId), error: \(error)")
    
    // 发送服务发现失败事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "servicesDiscoveryFailed",
        "deviceId": deviceId,
        "error": error
      ]
      eventSink(eventData)
    }
  }
  
  public func characteristicsDiscoveryFailed(_ deviceId: String, serviceId: String, error: String) {
    print("Characteristics discovery failed: \(deviceId), \(serviceId), error: \(error)")
    
    // 发送特征值发现失败事件到 Flutter
    if let eventSink = self.eventSink {
      let eventData: [String: Any] = [
        "type": "characteristicsDiscoveryFailed",
        "deviceId": deviceId,
        "serviceId": serviceId,
        "error": error
      ]
      eventSink(eventData)
    }
  }
}
