import 'dart:async';

import 'package:flutter/foundation.dart';

import 'device.dart';
import 'platform/platform_interface.dart';

/// 蓝牙状态枚举
///
/// 表示蓝牙适配器的当前状态
enum TimState {
  /// 未知状态
  unknown,

  /// 重置中
  resetting,

  /// 不支持蓝牙
  unsupported,

  /// 未授权
  unauthorized,

  /// 蓝牙已关闭
  poweredOff,

  /// 蓝牙已开启
  poweredOn,
}

/// OpenToy SDK 内部服务实现类
///
/// 此类负责处理所有蓝牙相关的底层操作，包括设备扫描、连接、数据传输等。
/// 通过平台接口与原生代码进行交互。
///
/// 注意：此类为内部实现，外部应通过 [OpenToy] 类使用相关功能。
class TimService {
  static final TimService _instance = TimService._internal();

  /// 获取Service单例实例
  static TimService get instance => _instance;

  TimService._internal();

  // 内部流控制器
  final StreamController<TimState> _stateController = StreamController.broadcast();
  final StreamController<TimDevice> _deviceDiscoveredController = StreamController.broadcast();
  final StreamController<TimDevice> _deviceConnectedController = StreamController.broadcast();
  final StreamController<TimDevice> _deviceDisconnectedController = StreamController.broadcast();

  // 内部缓存和状态管理
  final Map<String, TimDevice> _deviceCache = {};
  final Map<String, Completer<TimDevice>> _pendingConnections = {};
  bool _isInitialized = false;

  // 对外暴露的流接口
  Stream<TimState> get state => _stateController.stream;
  Stream<TimDevice> get deviceDiscovered => _deviceDiscoveredController.stream;
  Stream<TimDevice> get deviceConnected => _deviceConnectedController.stream;
  Stream<TimDevice> get deviceDisconnected => _deviceDisconnectedController.stream;

  /// 初始化服务
  ///
  /// 内部实现：初始化平台接口并开始监听事件
  Future<void> initialize() async {
    if (_isInitialized) return;

    await TimPlatform.instance.initialize();
    _listenToEvents();
    _isInitialized = true;
  }

  /// 开始扫描设备
  ///
  /// 内部实现：调用平台接口开始扫描蓝牙设备
  Future<void> startScan() async {
    await TimPlatform.instance.startScan();
  }

  /// 停止扫描设备
  ///
  /// 内部实现：调用平台接口停止扫描蓝牙设备
  Future<void> stopScan() async {
    await TimPlatform.instance.stopScan();
  }

  /// 连接设备
  ///
  /// 内部实现：处理设备连接逻辑，包括缓存检查和重复连接防护
  Future<TimDevice> connect(String deviceId) async {
    final cached = _deviceCache[deviceId];
    if (cached != null && cached.isConnected) {
      return cached;
    }

    final pending = _pendingConnections[deviceId];
    if (pending != null) {
      return pending.future;
    }

    final completer = Completer<TimDevice>();
    _pendingConnections[deviceId] = completer;

    try {
      await TimPlatform.instance.connectDevice(deviceId);
    } catch (error, stackTrace) {
      _pendingConnections.remove(deviceId);
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
      rethrow;
    }

    return completer.future;
  }

  /// 断开设备连接
  ///
  /// 内部实现：调用平台接口断开指定设备的连接
  Future<void> disconnect(String deviceId) async {
    await TimPlatform.instance.disconnectDevice(deviceId);
  }

  /// 读取设备电池电量
  ///
  /// 内部实现：调用平台接口读取设备电池电量
  /// 返回电池电量百分比 (0-100)
  Future<int> readBatteryLevel(String deviceId) async {
    return await TimPlatform.instance.readBatteryLevel(deviceId) ?? 0;
  }

  /// 写入电机控制数据
  ///
  /// 内部实现：调用平台接口写入电机PWM数据
  /// 使用 writeWithoutResponse 和队列执行，避免蓝牙协议栈堵塞
  Future<void> writeMotor(String deviceId, List<int> pwm) async {
    await TimPlatform.instance.writeMotor(deviceId, pwm);
  }

  /// 监听平台事件
  ///
  /// 内部实现：监听来自平台接口的事件流，并分发到相应的控制器
  void _listenToEvents() {
    TimPlatform.instance.events?.listen((event) {
      try {
        final normalizedEvent = Map<String, dynamic>.from(event.cast<String, dynamic>());
        final type = normalizedEvent['type'] as String?;

        switch (type) {
          case 'bluetoothStateChanged':
            final stateString = normalizedEvent['state'] as String?;
            final state = _parseBluetoothState(stateString);
            _stateController.add(state);
            break;

          case 'deviceDiscovered':
            final deviceData = normalizedEvent['device'];
            if (deviceData is Map) {
              final discoveryMap = Map<String, dynamic>.from(deviceData.cast<String, dynamic>());
              final deviceId = discoveryMap['deviceId']?.toString();
              if (deviceId == null || deviceId.isEmpty) {
                break;
              }
              final device = _updateDevice(
                deviceId: deviceId,
                name: discoveryMap['name']?.toString(),
                rssi: (discoveryMap['rssi'] as num?)?.toInt(),
                isConnected: false,
              );
              _deviceDiscoveredController.add(device);
            }
            break;

          case 'deviceConnected':
            final deviceId = normalizedEvent['deviceId'] as String?;
            if (deviceId == null || deviceId.isEmpty) {
              break;
            }

            final deviceInfoRaw = normalizedEvent['deviceInfo'];
            final info = deviceInfoRaw is Map
                ? TimDeviceInfo.fromMap(Map<String, dynamic>.from(deviceInfoRaw.cast<String, dynamic>()))
                : const TimDeviceInfo();

            final device = _updateDevice(deviceId: deviceId, isConnected: true, deviceInfo: info.isEmpty ? null : info);

            _deviceConnectedController.add(device);

            final completer = _pendingConnections.remove(deviceId);
            if (completer != null && !completer.isCompleted) {
              completer.complete(device);
            }
            break;

          case 'deviceDisconnected':
            final deviceId = normalizedEvent['deviceId'] as String?;
            if (deviceId != null && deviceId.isNotEmpty) {
              final device = _updateDevice(deviceId: deviceId, isConnected: false);
              _deviceDisconnectedController.add(device);

              final completer = _pendingConnections.remove(deviceId);
              if (completer != null && !completer.isCompleted) {
                final errorMessage = normalizedEvent['error'];
                completer.completeError(
                  StateError(
                    errorMessage == null
                        ? 'Connection cancelled for $deviceId'
                        : 'Connection cancelled for $deviceId: $errorMessage',
                  ),
                );
              }
            }
            break;

          case 'deviceConnectionFailed':
            final deviceId = normalizedEvent['deviceId'] as String?;
            if (deviceId != null && deviceId.isNotEmpty) {
              final completer = _pendingConnections.remove(deviceId);
              if (completer != null && !completer.isCompleted) {
                final errorDetail = normalizedEvent['error'];
                completer.completeError(
                  StateError(
                    errorDetail == null
                        ? 'Connection failed for $deviceId'
                        : 'Connection failed for $deviceId: $errorDetail',
                  ),
                );
              }
            }
            break;

          case 'batteryLevelUpdated':
            final deviceId = normalizedEvent['deviceId'] as String?;
            final batteryLevel = normalizedEvent['batteryLevel'] as int?;
            if (deviceId != null && deviceId.isNotEmpty && batteryLevel != null) {
              final existingDevice = _deviceCache[deviceId];
              if (existingDevice != null) {
                final updatedInfo = existingDevice.deviceInfo.copyWith(battery: batteryLevel);
                final updatedDevice = existingDevice.copyWith(deviceInfo: updatedInfo);
                _deviceCache[deviceId] = updatedDevice;
                // 发送设备更新事件
                _deviceConnectedController.add(updatedDevice);
              }
            }
            break;

          case 'batteryLevelReadFailed':
            // 电池读取失败，可以记录日志或发送错误事件
            final deviceId = normalizedEvent['deviceId'] as String?;
            final error = normalizedEvent['error'] as String?;
            if (deviceId != null && deviceId.isNotEmpty) {
              // 可以在这里添加错误处理逻辑
              debugPrint('Battery level read failed for device $deviceId: $error');
            }
            break;
        }
      } catch (e) {
        debugPrint('Error processing event: $e');
        debugPrint('Event data: $event');
      }
    });
  }

  /// 更新设备信息
  ///
  /// 内部实现：更新设备缓存中的设备信息，支持增量更新
  TimDevice _updateDevice({
    required String deviceId,
    String? name,
    int? rssi,
    bool? isConnected,
    TimDeviceInfo? deviceInfo,
  }) {
    if (deviceId.isEmpty) {
      throw ArgumentError('deviceId is required to update a device');
    }

    final existing =
        _deviceCache[deviceId] ?? TimDevice(deviceId: deviceId, name: name ?? 'Unknown Device', rssi: rssi ?? 0);

    final mergedInfo = deviceInfo == null
        ? null
        : existing.deviceInfo.copyWith(
            mac: deviceInfo.mac,
            variantCode: deviceInfo.variantCode,
            hardwareCode: deviceInfo.hardwareCode,
            firmwareVersion: deviceInfo.firmwareVersion,
            serialNumber: deviceInfo.serialNumber,
            battery: deviceInfo.battery,
          );

    final updated = existing.copyWith(name: name, rssi: rssi, isConnected: isConnected, deviceInfo: mergedInfo);

    _deviceCache[deviceId] = updated;
    return updated;
  }

  /// 解析蓝牙状态字符串
  ///
  /// 内部实现：将平台返回的状态字符串转换为枚举值
  TimState _parseBluetoothState(String? stateString) {
    switch (stateString) {
      case 'unknown':
        return TimState.unknown;
      case 'resetting':
        return TimState.resetting;
      case 'unsupported':
        return TimState.unsupported;
      case 'unauthorized':
        return TimState.unauthorized;
      case 'poweredOff':
        return TimState.poweredOff;
      case 'poweredOn':
        return TimState.poweredOn;
      default:
        return TimState.unknown;
    }
  }
}
