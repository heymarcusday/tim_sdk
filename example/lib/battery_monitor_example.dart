import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tim_sdk/tim_sdk.dart';

/// 电池电量监控示例
///
/// 展示如何定期读取设备的电池电量，并监听电量变化
class BatteryMonitorExample extends StatefulWidget {
  const BatteryMonitorExample({super.key});

  @override
  State<BatteryMonitorExample> createState() => _BatteryMonitorExampleState();
}

class _BatteryMonitorExampleState extends State<BatteryMonitorExample> {
  final TimSdk _timSdk = TimSdk();
  String? _connectedDeviceId;
  int? _batteryLevel;
  Timer? _batteryTimer;
  String _status = '未连接设备';

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    super.dispose();
  }

  /// 初始化蓝牙
  Future<void> _initializeBluetooth() async {
    try {
      final result = await _timSdk.initializeBluetooth();
      setState(() {
        _status = result == true ? '蓝牙已初始化，请连接设备' : '蓝牙初始化失败';
      });
    } catch (e) {
      setState(() {
        _status = '蓝牙初始化失败: $e';
      });
    }
  }

  /// 连接设备
  Future<void> _connectToDevice(String deviceId) async {
    try {
      final result = await _timSdk.connectToDevice(deviceId);
      setState(() {
        _connectedDeviceId = result == true ? deviceId : null;
        _status = result == true ? '设备已连接: $deviceId' : '连接失败';
      });

      // 设备连接后开始定期读取电池电量
      if (result == true) {
        _startBatteryMonitoring();
      }
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
        _batteryLevel = null;
        _status = result == true ? '设备已断开' : '断开失败';
      });

      // 停止电池电量监控
      if (result == true) {
        _stopBatteryMonitoring();
      }
    } catch (e) {
      setState(() {
        _status = '断开失败: $e';
      });
    }
  }

  /// 开始电池电量监控
  void _startBatteryMonitoring() {
    _stopBatteryMonitoring(); // 先停止之前的监控

    // 立即读取一次电池电量
    _readBatteryLevel();

    // 每30秒读取一次电池电量
    _batteryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _readBatteryLevel();
    });
  }

  /// 停止电池电量监控
  void _stopBatteryMonitoring() {
    _batteryTimer?.cancel();
    _batteryTimer = null;
  }

  /// 读取电池电量
  Future<void> _readBatteryLevel() async {
    if (_connectedDeviceId == null) return;

    try {
      final batteryLevel = await _timSdk.readBatteryLevel(_connectedDeviceId!);
      setState(() {
        _batteryLevel = batteryLevel;
      });
    } catch (e) {
      debugPrint('读取电池电量失败: $e');
    }
  }

  /// 手动读取电池电量
  Future<void> _manualReadBattery() async {
    if (_connectedDeviceId == null) return;

    setState(() {
      _status = '正在读取电池电量...';
    });

    try {
      final batteryLevel = await _timSdk.readBatteryLevel(_connectedDeviceId!);
      setState(() {
        _batteryLevel = batteryLevel;
        _status = batteryLevel != null ? '电池电量读取成功: $batteryLevel%' : '读取电池电量失败';
      });
    } catch (e) {
      setState(() {
        _status = '读取电池电量失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('电池电量监控示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
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

            // 电池电量显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('电池电量', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_batteryLevel != null) ...[
                      Text('当前电量: $_batteryLevel%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _batteryLevel! / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(_batteryLevel! > 20 ? Colors.green : Colors.red),
                      ),
                    ] else ...[
                      const Text('暂无电池电量数据', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 控制按钮
            if (_connectedDeviceId != null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(onPressed: _manualReadBattery, child: const Text('手动读取电量')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _batteryTimer != null ? _stopBatteryMonitoring : _startBatteryMonitoring,
                      child: Text(_batteryTimer != null ? '停止监控' : '开始监控'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text('请先连接设备以监控电池电量', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],

            const SizedBox(height: 16),

            // 监控状态
            if (_batteryTimer != null) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.monitor_heart, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        '正在监控电池电量（每30秒读取一次）',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
