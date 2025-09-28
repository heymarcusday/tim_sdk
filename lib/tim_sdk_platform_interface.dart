import 'dart:async';
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

  // 蓝牙相关方法
  Future<bool?> initializeBluetooth() {
    throw UnimplementedError('initializeBluetooth() has not been implemented.');
  }

  Future<bool?> startScan() {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<bool?> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Future<bool?> connectToDevice(String deviceId) {
    throw UnimplementedError('connectToDevice() has not been implemented.');
  }

  Future<bool?> disconnectFromDevice(String deviceId) {
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
