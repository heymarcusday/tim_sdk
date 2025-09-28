import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tim_sdk/tim_sdk.dart';

/// 电池电量读取示例
///
/// 展示两种不同的电池电量读取方式：
/// 1. 一次性读取（直接返回结果）
/// 2. 持续监听（通过事件流）
class BatteryExamples extends StatefulWidget {
  const BatteryExamples({super.key});

  @override
  State<BatteryExamples> createState() => _BatteryExamplesState();
}

class _BatteryExamplesState extends State<BatteryExamples> {
  final TimSdk _timSdk = TimSdk();
  String? _connectedDeviceId;
  int? _directBatteryLevel;
  int? _eventBatteryLevel;
  String _status = '未连接设备';
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  /// 初始化蓝牙
  Future<void> _initializeBluetooth() async {
    try {
      final result = await _timSdk.initializeBluetooth();
      _listenToEvents();
      setState(() {
        _status = result == true ? '蓝牙已初始化，请连接设备' : '蓝牙初始化失败';
      });
    } catch (e) {
      setState(() {
        _status = '蓝牙初始化失败: $e';
      });
    }
  }

  /// 监听事件
  void _listenToEvents() {
    // 注意：tim_sdk 目前没有事件流，这里只是示例结构
    // 实际实现需要根据 tim_sdk 的事件机制来调整
  }

  /// 连接设备
  Future<void> _connectToDevice(String deviceId) async {
    try {
      final result = await _timSdk.connectToDevice(deviceId);
      setState(() {
        _connectedDeviceId = result == true ? deviceId : null;
        _status = result == true ? '设备已连接' : '连接失败';
      });
    } catch (e) {
      setState(() {
        _status = '连接失败: $e';
      });
    }
  }

  /// 断开设备
  Future<void> _disconnectFromDevice() async {
    if (_connectedDeviceId == null) return;

    try {
      final result = await _timSdk.disconnectFromDevice(_connectedDeviceId!);
      setState(() {
        _connectedDeviceId = result == true ? null : _connectedDeviceId;
        _eventBatteryLevel = null;
        _directBatteryLevel = null;
        _status = result == true ? '设备已断开' : '断开失败';
      });
    } catch (e) {
      setState(() {
        _status = '断开失败: $e';
      });
    }
  }

  /// 方式1：一次性读取电池电量（直接返回结果）
  Future<void> _readBatteryDirectly() async {
    if (_connectedDeviceId == null) return;

    setState(() {
      _status = '正在直接读取电池电量...';
    });

    try {
      final batteryLevel = await _timSdk.readBatteryLevel(_connectedDeviceId!);
      setState(() {
        _directBatteryLevel = batteryLevel;
        _status = batteryLevel != null ? '直接读取成功: $batteryLevel%' : '直接读取失败';
      });
    } catch (e) {
      setState(() {
        _status = '直接读取失败: $e';
      });
    }
  }

  /// 方式2：通过事件流监听电池电量变化
  void _startEventMonitoring() {
    if (_connectedDeviceId == null) return;

    setState(() {
      _status = '开始监听电池电量变化...';
    });

    // 注意：这里需要根据 tim_sdk 的实际事件机制来实现
    // 目前只是示例结构
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('电池电量读取示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('状态: $_status', style: const TextStyle(fontSize: 16)),
                    if (_connectedDeviceId != null) ...[
                      const SizedBox(height: 8),
                      Text('设备ID: $_connectedDeviceId', style: const TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 设备连接控制
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('设备连接', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (_connectedDeviceId == null) ...[
                      const Text('请输入设备ID进行连接', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: '设备ID',
                          hintText: '输入设备ID',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _connectToDevice(value);
                          }
                        },
                      ),
                    ] else ...[
                      Text('已连接设备: $_connectedDeviceId', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _disconnectFromDevice, child: const Text('断开连接')),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 方式1：直接读取
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('方式1：直接读取电池电量', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      '使用 FlutterResult 直接返回电池电量值，适合一次性读取场景。',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    if (_directBatteryLevel != null) ...[
                      Text('直接读取结果: $_directBatteryLevel%', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _directBatteryLevel! / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _directBatteryLevel! > 20 ? Colors.green : Colors.red,
                        ),
                      ),
                    ] else ...[
                      const Text('暂无直接读取数据', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                    const SizedBox(height: 12),
                    if (_connectedDeviceId != null)
                      ElevatedButton(onPressed: _readBatteryDirectly, child: const Text('直接读取电池电量')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 方式2：事件监听
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('方式2：事件流监听电池电量', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      '通过 EventChannel 监听电池电量变化，适合持续监控场景。',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    if (_eventBatteryLevel != null) ...[
                      Text('事件监听结果: $_eventBatteryLevel%', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _eventBatteryLevel! / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _eventBatteryLevel! > 20 ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ] else ...[
                      const Text('暂无事件监听数据', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                    const SizedBox(height: 12),
                    if (_connectedDeviceId != null)
                      ElevatedButton(onPressed: _startEventMonitoring, child: const Text('开始事件监听')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 使用建议
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('使用建议', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      '• 一次性读取：适合用户主动查询电池电量的场景\n'
                      '• 事件监听：适合需要持续监控电池电量变化的场景\n'
                      '• 两种方式可以同时使用，互不冲突',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
