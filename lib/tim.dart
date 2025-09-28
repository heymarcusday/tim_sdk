import 'dart:async';

import 'package:tim/src/device.dart';

import 'src/service.dart';

export 'src/device.dart';
export 'src/service.dart';

class Tim {
  static final Tim _instance = Tim._internal();
  static Tim get instance => _instance;
  final TimService _service = TimService.instance;

  Tim._internal();

  // 蓝牙相关方法
  Future<void> initialize() {
    return _service.initialize();
  }

  Future<void> startScan() {
    return _service.startScan();
  }

  Future<void> stopScan() {
    return _service.stopScan();
  }

  Future<TimDevice> connect(String deviceId) {
    return _service.connect(deviceId);
  }

  Future<void> disconnect(String deviceId) {
    return _service.disconnect(deviceId);
  }

  Future<int?> readBatteryLevel(String deviceId) {
    return _service.readBatteryLevel(deviceId);
  }

  Future<void> writeMotor(String deviceId, List<int> pwm) {
    return _service.writeMotor(deviceId, pwm);
  }

  // 事件流
  Stream<TimState> get state => _service.state;
  Stream<TimDevice> get deviceDiscovered => _service.deviceDiscovered;
  Stream<TimDevice> get deviceConnected => _service.deviceConnected;
  Stream<TimDevice> get deviceDisconnected => _service.deviceDisconnected;
}
