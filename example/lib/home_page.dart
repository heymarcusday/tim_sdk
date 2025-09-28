import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tim_sdk/tim_sdk.dart';
import 'device_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TimSdk _timSdk = TimSdk();
  String _bluetoothStatus = '未知';
  final List<Map<String, dynamic>> _discoveredDevices = [];
  String? _selectedDeviceId;
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isStartingScan = false;
  bool _isStoppingScan = false;
  bool _isScanning = false;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _listenToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    _eventSubscription = _timSdk.events?.listen((event) {
      if (!mounted) return;

      final eventType = event['type'] as String?;
      switch (eventType) {
        case 'deviceDiscovered':
          final device = event['device'] as Map<String, dynamic>?;
          if (device != null) {
            setState(() {
              // 检查设备是否已存在，避免重复添加
              final deviceId = device['deviceId'] as String?;
              if (deviceId != null) {
                final existingIndex = _discoveredDevices.indexWhere((d) => d['deviceId'] == deviceId);
                if (existingIndex >= 0) {
                  _discoveredDevices[existingIndex] = device;
                } else {
                  _discoveredDevices.add(device);
                }
              }
            });
          }
          break;

        case 'deviceConnected':
          final deviceId = event['deviceId'] as String?;
          final deviceInfo = event['deviceInfo'] as Map<String, dynamic>?;
          if (deviceId != null) {
            setState(() {
              _selectedDeviceId = deviceId;
              _bluetoothStatus = '设备已连接: $deviceId';
            });
            _showSnackBar('设备已连接: $deviceId');
          }
          break;

        case 'deviceDisconnected':
          final deviceId = event['deviceId'] as String?;
          final error = event['error'] as String?;
          if (deviceId != null) {
            setState(() {
              if (_selectedDeviceId == deviceId) {
                _selectedDeviceId = null;
                _bluetoothStatus = '设备已断开: $deviceId';
              }
            });
            _showSnackBar(error != null && error.isNotEmpty ? '设备断开: $error' : '设备已断开: $deviceId');
          }
          break;

        case 'deviceConnectionFailed':
          final deviceId = event['deviceId'] as String?;
          final error = event['error'] as String?;
          if (deviceId != null) {
            _showSnackBar('连接失败: $deviceId - ${error ?? "未知错误"}');
          }
          break;

        case 'bluetoothStateChanged':
          final state = event['state'] as String?;
          if (state != null) {
            setState(() {
              _bluetoothStatus = '蓝牙状态: $state';
            });
          }
          break;

        case 'characteristicValueUpdated':
          final deviceId = event['deviceId'] as String?;
          final characteristicId = event['characteristicId'] as String?;
          final data = event['data'] as List<int>?;
          debugPrint('特征值更新: $deviceId, $characteristicId, $data');
          break;

        case 'characteristicReadFailed':
        case 'characteristicWriteFailed':
        case 'servicesDiscoveryFailed':
        case 'characteristicsDiscoveryFailed':
          final deviceId = event['deviceId'] as String?;
          final error = event['error'] as String?;
          debugPrint('蓝牙操作失败: $eventType - $deviceId - $error');
          break;

        case 'characteristicWriteSuccess':
          final deviceId = event['deviceId'] as String?;
          final characteristicId = event['characteristicId'] as String?;
          debugPrint('特征值写入成功: $deviceId, $characteristicId');
          break;
      }
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
      final result = await _timSdk.initializeBluetooth();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isInitialized = result == true;
        _bluetoothStatus = result == true ? '已初始化' : '初始化失败';
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
    });

    try {
      final result = await _timSdk.startScan();
      if (!mounted) return;
      setState(() {
        _isStartingScan = false;
        _isScanning = result == true;
        _discoveredDevices.clear();
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
      final result = await _timSdk.stopScan();
      if (!mounted) return;
      setState(() {
        _isStoppingScan = false;
        _isScanning = result != true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStoppingScan = false;
      });
      _showSnackBar('停止扫描失败: $e');
    }
  }

  void _openDeviceDetail(BuildContext context, String deviceId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPage(deviceId: deviceId, deviceName: '设备 $deviceId', initialIsConnected: false),
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
      final isConnected = _selectedDeviceId == deviceId;

      return Card(
        child: ListTile(
          onTap: () => _openDeviceDetail(context, deviceId),
          title: Text(deviceName, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            'ID: $deviceId\nRSSI: $rssi',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
