import Flutter
import UIKit
import opentoy_ios

public class TimSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tim_sdk", binaryMessenger: registrar.messenger())
    let instance = TimSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getOpenToyVersion":
      Task { @MainActor in
        result(OpenToyIOS.shared.getVersion())
      }
    case "getOpenToyDeviceInfo":
      Task { @MainActor in
        let deviceInfo = OpenToyIOS.shared.getDeviceInfo()
        result(deviceInfo)
      }
    case "performOpenToyOperation":
      if let args = call.arguments as? [String: Any],
         let operation = args["operation"] as? String {
        Task { @MainActor in
          let response = OpenToyIOS.shared.performOperation(operation)
          result(response)
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Operation parameter is required", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
