import 'tim_sdk_platform_interface.dart';

class TimSdk {
  Future<String?> getPlatformVersion() {
    return TimSdkPlatform.instance.getPlatformVersion();
  }

  Future<String?> getOpenToyVersion() {
    return TimSdkPlatform.instance.getOpenToyVersion();
  }

  Future<Map<String, dynamic>?> getOpenToyDeviceInfo() {
    return TimSdkPlatform.instance.getOpenToyDeviceInfo();
  }

  Future<String?> performOpenToyOperation(String operation) {
    return TimSdkPlatform.instance.performOpenToyOperation(operation);
  }
}
