import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tim_sdk/tim_sdk.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.initialIsConnected,
  });

  final String deviceId;
  final String deviceName;
  final bool initialIsConnected;

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final TimSdk _timSdk = TimSdk();
  late bool _isConnected;
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  bool _isReadingBattery = false;
  int? _currentBatteryLevel;
  String _batteryStatus = '';
  int _currentPwm = 0; // 单电机模式

  @override
  void initState() {
    super.initState();
    _isConnected = widget.initialIsConnected;
  }

  Future<void> _connect() async {
    if (_isConnecting || _isConnected) {
      return;
    }
    setState(() {
      _isConnecting = true;
    });

    try {
      final result = await _timSdk.connectToDevice(widget.deviceId);
      if (!mounted) return;
      setState(() {
        _isConnected = result == true;
        _isConnecting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
      });
      _showSnackBar('连接失败: $e');
    }
  }

  Future<void> _disconnect() async {
    if (_isDisconnecting || !_isConnected) {
      return;
    }
    setState(() {
      _isDisconnecting = true;
    });

    try {
      final result = await _timSdk.disconnectFromDevice(widget.deviceId);
      if (!mounted) return;
      setState(() {
        _isConnected = result != true;
        _isDisconnecting = false;
        if (result == true) {
          _resetState();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDisconnecting = false;
      });
      _showSnackBar('断开失败: $e');
    }
  }

  void _resetState() {
    _currentBatteryLevel = null;
    _batteryStatus = '';
    _currentPwm = 0;
  }

  /// 读取电池电量
  Future<void> _readBatteryLevel() async {
    if (!_isConnected || _isReadingBattery) {
      return;
    }

    setState(() {
      _isReadingBattery = true;
      _batteryStatus = '正在读取电池电量...';
    });

    try {
      debugPrint('开始读取设备 ${widget.deviceId} 的电池电量...');
      final batteryLevel = await _timSdk.readBatteryLevel(widget.deviceId);
      debugPrint('电池电量读取成功: $batteryLevel%');

      if (!mounted) return;

      setState(() {
        _currentBatteryLevel = batteryLevel;
        _batteryStatus = batteryLevel != null ? '电池电量读取成功: $batteryLevel%' : '电池电量读取失败';
        _isReadingBattery = false;
      });
    } catch (e) {
      debugPrint('电池电量读取失败: $e');
      if (!mounted) return;

      setState(() {
        _batteryStatus = '电池电量读取失败: $e';
        _isReadingBattery = false;
      });
    }
  }

  /// 写入电机控制数据
  Future<void> _writeMotor(int pwm) async {
    if (!_isConnected) {
      return;
    }

    debugPrint('发送电机控制数据: PWM=$pwm');
    try {
      final result = await _timSdk.writeMotor(widget.deviceId, [pwm]);
      if (result != true) {
        _showSnackBar('电机控制失败');
      }
    } catch (error) {
      debugPrint('电机控制失败: $error');
      _showSnackBar('电机控制失败: $error');
    }
  }

  /// 停止电机
  void _stopMotor() {
    setState(() {
      _currentPwm = 0;
    });
    _writeMotor(0);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 构建电池电量显示部分
  List<Widget> _buildBatterySection(TextTheme textTheme, ColorScheme colorScheme) {
    if (!_isConnected) {
      return [];
    }

    return [
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.battery_std, size: 20),
                  const SizedBox(width: 8),
                  Text('电池电量', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              if (_currentBatteryLevel != null) ...[
                Row(
                  children: [
                    Text(
                      '当前电量: $_currentBatteryLevel%',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentBatteryLevel! > 20 ? Icons.battery_full : Icons.battery_alert,
                      color: _currentBatteryLevel! > 20 ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _currentBatteryLevel! / 100.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_currentBatteryLevel! > 20 ? Colors.green : Colors.red),
                ),
              ] else ...[
                const Text('暂无电池电量数据', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
              if (_batteryStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_batteryStatus, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isReadingBattery ? null : _readBatteryLevel,
                child: _isReadingBattery
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('读取中...'),
                        ],
                      )
                    : const Text('读取电池电量'),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// 构建电机控制部分
  List<Widget> _buildMotorControlSection(TextTheme textTheme, ColorScheme colorScheme) {
    if (!_isConnected) {
      return [];
    }

    return [
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings, size: 20),
                  const SizedBox(width: 8),
                  Text('电机控制', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),

              // 当前PWM值显示
              Text('当前PWM: $_currentPwm', style: textTheme.bodyMedium),
              const SizedBox(height: 8),

              // PWM滑块控制（实时生效）
              Row(
                children: [
                  const Text('PWM: '),
                  Expanded(
                    child: Slider(
                      value: _currentPwm.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20, // 每5个单位一个刻度
                      onChanged: (value) {
                        setState(() {
                          _currentPwm = value.round();
                        });
                        // 实时发送PWM值
                        _writeMotor(_currentPwm);
                      },
                    ),
                  ),
                  Text('$_currentPwm', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),

              // 停止按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _stopMotor,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('停止'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 预设控制按钮
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPwm = 50;
                      });
                      _writeMotor(50);
                    },
                    child: const Text('50%'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPwm = 75;
                      });
                      _writeMotor(75);
                    },
                    child: const Text('75%'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPwm = 100;
                      });
                      _writeMotor(100);
                    },
                    child: const Text('100%'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final baseButtonStyle = theme.elevatedButtonTheme.style;
    final canConnect = !_isConnected && !_isConnecting;
    final canDisconnect = _isConnected && !_isDisconnecting;
    final isProgressVisible = _isConnecting || _isDisconnecting;
    final progressLabel = _isDisconnecting ? '断开中...' : '连接中...';

    return Scaffold(
      appBar: AppBar(title: Text(widget.deviceName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(widget.deviceName, style: textTheme.titleLarge)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isConnected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _isConnected ? '已连接' : '未连接',
                            style:
                                textTheme.labelSmall?.copyWith(
                                  color: _isConnected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ) ??
                                TextStyle(
                                  color: _isConnected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '设备ID: ${widget.deviceId}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            ..._buildBatterySection(textTheme, colorScheme),
            ..._buildMotorControlSection(textTheme, colorScheme),
            const SizedBox(height: 16),
            Text('操作', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: canConnect ? _connect : null,
                  child: _isConnecting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('连接中...'),
                          ],
                        )
                      : const Text('连接'),
                ),
                ElevatedButton(
                  onPressed: canDisconnect ? _disconnect : null,
                  style: baseButtonStyle?.copyWith(
                    backgroundColor: WidgetStatePropertyAll(colorScheme.error),
                    foregroundColor: WidgetStatePropertyAll(colorScheme.onError),
                  ),
                  child: _isDisconnecting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('断开中...'),
                          ],
                        )
                      : const Text('断开'),
                ),
              ],
            ),
            if (isProgressVisible) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_isDisconnecting ? colorScheme.error : colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(progressLabel, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
