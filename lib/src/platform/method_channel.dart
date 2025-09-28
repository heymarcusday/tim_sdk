import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'platform_interface.dart';

/// An implementation of [TimPlatform] that uses method channels.
class MethodChannelTimSdk extends TimPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tim');

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('tim/events');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // 蓝牙相关方法
  @override
  Future<bool?> initialize() async {
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
  Future<bool?> connectDevice(String deviceId) async {
    final result = await methodChannel.invokeMethod<bool>('connectToDevice', {'deviceId': deviceId});
    return result;
  }

  @override
  Future<bool?> disconnectDevice(String deviceId) async {
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

  @override
  Stream<Map<String, dynamic>>? get events {
    return eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(
          event.map((key, value) {
            if (value is Map) {
              return MapEntry(key as String, Map<String, dynamic>.from(value.cast<String, dynamic>()));
            }
            return MapEntry(key as String, value);
          }),
        );
      }
      return <String, dynamic>{};
    });
  }
}
