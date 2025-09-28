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
}
