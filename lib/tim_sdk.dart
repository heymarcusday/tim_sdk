
import 'tim_sdk_platform_interface.dart';

class TimSdk {
  Future<String?> getPlatformVersion() {
    return TimSdkPlatform.instance.getPlatformVersion();
  }
}
