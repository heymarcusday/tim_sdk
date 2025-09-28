import 'dart:async';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel.dart';

abstract class TimPlatform extends PlatformInterface {
  /// Constructs a TimSdkPlatform.
  TimPlatform() : super(token: _token);

  static final Object _token = Object();

  static TimPlatform _instance = MethodChannelTimSdk();

  /// The default instance of [TimPlatform] to use.
  ///
  /// Defaults to [MethodChannelTimSdk].
  static TimPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TimPlatform] when
  /// they register themselves.
  static set instance(TimPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // 蓝牙相关方法
  Future<bool?> initialize() {
    throw UnimplementedError('initializeBluetooth() has not been implemented.');
  }

  Future<bool?> startScan() {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<bool?> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Future<bool?> connectDevice(String deviceId) {
    throw UnimplementedError('connectToDevice() has not been implemented.');
  }

  Future<bool?> disconnectDevice(String deviceId) {
    throw UnimplementedError('disconnectFromDevice() has not been implemented.');
  }

  Future<int?> readBatteryLevel(String deviceId) {
    throw UnimplementedError('readBatteryLevel() has not been implemented.');
  }

  Future<bool?> writeMotor(String deviceId, List<int> pwm) {
    throw UnimplementedError('writeMotor() has not been implemented.');
  }

  // 事件流
  Stream<Map<String, dynamic>>? get events {
    throw UnimplementedError('events has not been implemented.');
  }
}
