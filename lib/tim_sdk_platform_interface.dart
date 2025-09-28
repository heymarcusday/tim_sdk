import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tim_sdk_method_channel.dart';

abstract class TimSdkPlatform extends PlatformInterface {
  /// Constructs a TimSdkPlatform.
  TimSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static TimSdkPlatform _instance = MethodChannelTimSdk();

  /// The default instance of [TimSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelTimSdk].
  static TimSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TimSdkPlatform] when
  /// they register themselves.
  static set instance(TimSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
