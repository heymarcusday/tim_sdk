import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tim/tim.dart';
import 'device_detail_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onThemeToggle;

  const HomePage({super.key, this.onThemeToggle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Tim _tim = Tim.instance;
  String _bluetoothStatus = '未知';
  final List<Map<String, dynamic>> _discoveredDevices = [];
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isStartingScan = false;
  bool _isStoppingScan = false;
  bool _isScanning = false;
  StreamSubscription<TimDevice>? _eventSubscription;
  StreamSubscription<TimDevice>? _deviceConnectionSubscription;
  StreamSubscription<TimDevice>? _deviceDisconnectionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _setupEventListeners();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _deviceConnectionSubscription?.cancel();
    _deviceDisconnectionSubscription?.cancel();
    super.dispose();
  }

  void _setupEventListeners() {
    // 监听设备发现事件
    _eventSubscription = _tim.deviceDiscovered.where((e) => e.name == 'GOSH').listen((device) {
      if (!mounted) return;
      setState(() {
        // 避免重复添加设备
        final deviceId = device.deviceId;
        if (!_discoveredDevices.any((d) => d['deviceId'] == deviceId)) {
          _discoveredDevices.add({
            'deviceId': device.deviceId,
            'name': device.name,
            'rssi': device.rssi,
            'isConnected': device.isConnected,
            'deviceInfo': device.deviceInfo.toMap(),
          });
        }
      });
    });

    // 监听设备连接状态变化
    _deviceConnectionSubscription = _tim.deviceConnected.listen((device) {
      if (!mounted) return;
      setState(() {
        final deviceIndex = _discoveredDevices.indexWhere((d) => d['deviceId'] == device.deviceId);
        if (deviceIndex != -1) {
          _discoveredDevices[deviceIndex]['isConnected'] = device.isConnected;
        }
      });
    });

    // 监听设备断开连接事件
    _deviceDisconnectionSubscription = _tim.deviceDisconnected.listen((device) {
      if (!mounted) return;
      setState(() {
        final deviceIndex = _discoveredDevices.indexWhere((d) => d['deviceId'] == device.deviceId);
        if (deviceIndex != -1) {
          _discoveredDevices[deviceIndex]['isConnected'] = false;
        }
      });
    });
  }

  Future<void> _initializeBluetooth() async {
    if (_isInitializing || _isInitialized) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    try {
      await _tim.initialize();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isInitialized = true;
        _bluetoothStatus = '已初始化';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _bluetoothStatus = '初始化失败: $e';
      });
      _showSnackBar('蓝牙初始化失败: $e');
    }
  }

  Future<void> _startScan() async {
    if (_isStartingScan || _isScanning) {
      return;
    }

    setState(() {
      _isStartingScan = true;
      _discoveredDevices.clear();
    });

    try {
      await _tim.startScan();
      if (!mounted) return;
      setState(() {
        _isStartingScan = false;
        _isScanning = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStartingScan = false;
        _isScanning = false;
      });
      _showSnackBar('开始扫描失败: $e');
    }
  }

  Future<void> _stopScan() async {
    if (!_isScanning || _isStoppingScan) {
      return;
    }

    setState(() {
      _isStoppingScan = true;
    });

    try {
      await _tim.stopScan();
      if (!mounted) return;
      setState(() {
        _isStoppingScan = false;
        _isScanning = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStoppingScan = false;
      });
      _showSnackBar('停止扫描失败: $e');
    }
  }

  void _openDeviceDetail(BuildContext context, Map<String, dynamic> device) {
    final deviceId = device['deviceId'] as String? ?? '';
    final deviceName = device['name'] as String? ?? 'Unknown Device';
    final isConnected = device['isConnected'] as bool? ?? false;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPage(deviceId: deviceId, deviceName: deviceName, initialIsConnected: isConnected),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final baseButtonStyle = theme.elevatedButtonTheme.style;
    final canInitialize = !_isInitialized && !_isInitializing;
    final canStartScan = _isInitialized && !_isStartingScan && !_isScanning;
    final canStopScan = _isScanning && !_isStoppingScan;
    final isScanStatusVisible = _isStartingScan || _isScanning || _isStoppingScan;
    final scanningStatusLabel = _isStoppingScan
        ? '停止扫描中...'
        : _isStartingScan
        ? '开始扫描中...'
        : '扫描中...';

    return Scaffold(
      appBar: AppBar(title: const Text('TIM SDK 蓝牙演示')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Text('蓝牙状态: ', style: textTheme.bodyMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isInitialized ? colorScheme.primaryContainer : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _bluetoothStatus,
                    style:
                        textTheme.labelSmall?.copyWith(
                          color: _isInitialized ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          color: _isInitialized ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: canInitialize ? _initializeBluetooth : null,
                  child: _isInitializing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('初始化中...'),
                          ],
                        )
                      : const Text('初始化蓝牙'),
                ),
                ElevatedButton(
                  onPressed: canStartScan ? _startScan : null,
                  style: baseButtonStyle?.copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return colorScheme.surfaceContainerHighest;
                      }
                      return colorScheme.tertiary;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return colorScheme.onSurfaceVariant;
                      }
                      return colorScheme.onTertiary;
                    }),
                  ),
                  child: _isStartingScan
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('开始中...'),
                          ],
                        )
                      : const Text('开始扫描'),
                ),
                ElevatedButton(
                  onPressed: canStopScan ? _stopScan : null,
                  style: baseButtonStyle?.copyWith(
                    backgroundColor: WidgetStatePropertyAll(colorScheme.secondary),
                    foregroundColor: WidgetStatePropertyAll(colorScheme.onSecondary),
                  ),
                  child: _isStoppingScan
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('停止中...'),
                          ],
                        )
                      : const Text('停止扫描'),
                ),
              ],
            ),
            if (isScanStatusVisible) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_isStoppingScan ? colorScheme.error : colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(scanningStatusLabel, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('已发现设备:', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_discoveredDevices.isEmpty) ...[
              const Text('暂无发现的设备', style: TextStyle(color: Colors.grey)),
            ] else ...[
              ..._buildDiscoveredDevices(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDiscoveredDevices() {
    return _discoveredDevices.map((device) {
      final deviceId = device['deviceId'] as String? ?? 'Unknown';
      final deviceName = device['name'] as String? ?? 'Unknown Device';
      final rssi = device['rssi'] as int? ?? 0;
      final isConnected = device['isConnected'] as bool? ?? false;
      final deviceInfo = device['deviceInfo'] as Map<String, dynamic>?;
      final battery = deviceInfo?['battery'] as int?;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: () => _openDeviceDetail(context, device),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.bluetooth, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          title: Text(deviceName, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: $deviceId',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'RSSI: $rssi dBm',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (battery != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.battery_std, size: 16, color: battery > 20 ? Colors.green : Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '$battery%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: battery > 20 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '已连接',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      );
    }).toList();
  }
}
