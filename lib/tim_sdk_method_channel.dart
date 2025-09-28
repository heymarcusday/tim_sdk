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

  // 蓝牙相关方法
  @override
  Future<bool?> initializeBluetooth() async {
    final result = await methodChannel.invokeMethod<bool>('initializeBluetooth');
    return result;
  }

  @override
  Future<bool?> startScan() async {
    final result = await methodChannel.invokeMethod<bool>('startScan');
    return result;
  }

  @override
  Future<bool?> stopScan() async {
    final result = await methodChannel.invokeMethod<bool>('stopScan');
    return result;
  }

  @override
  Future<bool?> connectToDevice(String deviceId) async {
    final result = await methodChannel.invokeMethod<bool>('connectToDevice', {'deviceId': deviceId});
    return result;
  }

  @override
  Future<bool?> disconnectFromDevice(String deviceId) async {
    final result = await methodChannel.invokeMethod<bool>('disconnectFromDevice', {'deviceId': deviceId});
    return result;
  }

  @override
  Future<int?> readBatteryLevel(String deviceId) async {
    final result = await methodChannel.invokeMethod<int>('readBatteryLevel', {'deviceId': deviceId});
    return result;
  }

  @override
  Future<bool?> writeMotor(String deviceId, List<int> pwm) async {
    final result = await methodChannel.invokeMethod<bool>('writeMotor', {'deviceId': deviceId, 'pwm': pwm});
    return result;
  }
}
