import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tim_sdk_platform_interface.dart';

/// An implementation of [TimSdkPlatform] that uses method channels.
class MethodChannelTimSdk extends TimSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tim_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> getOpenToyVersion() async {
    final version = await methodChannel.invokeMethod<String>('getOpenToyVersion');
    return version;
  }

  @override
  Future<Map<String, dynamic>?> getOpenToyDeviceInfo() async {
    final deviceInfo = await methodChannel.invokeMethod<Map<Object?, Object?>>('getOpenToyDeviceInfo');
    return deviceInfo?.cast<String, dynamic>();
  }

  @override
  Future<String?> performOpenToyOperation(String operation) async {
    final result = await methodChannel.invokeMethod<String>('performOpenToyOperation', {'operation': operation});
    return result;
  }
}
