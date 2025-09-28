import 'dart:async';
import 'tim_sdk_platform_interface.dart';

class TimSdk {
  Future<String?> getPlatformVersion() {
    return TimSdkPlatform.instance.getPlatformVersion();
  }

  // 蓝牙相关方法
  Future<bool?> initializeBluetooth() {
    return TimSdkPlatform.instance.initializeBluetooth();
  }

  Future<bool?> startScan() {
    return TimSdkPlatform.instance.startScan();
  }

  Future<bool?> stopScan() {
    return TimSdkPlatform.instance.stopScan();
  }

  Future<bool?> connectToDevice(String deviceId) {
    return TimSdkPlatform.instance.connectToDevice(deviceId);
  }

  Future<bool?> disconnectFromDevice(String deviceId) {
    return TimSdkPlatform.instance.disconnectFromDevice(deviceId);
  }

  Future<int?> readBatteryLevel(String deviceId) {
    return TimSdkPlatform.instance.readBatteryLevel(deviceId);
  }

  Future<bool?> writeMotor(String deviceId, List<int> pwm) {
    return TimSdkPlatform.instance.writeMotor(deviceId, pwm);
  }

  // 事件流
  Stream<Map<String, dynamic>>? get events {
    return TimSdkPlatform.instance.events;
  }
}
