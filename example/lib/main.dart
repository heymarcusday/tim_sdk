import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tim_sdk/tim_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _openToyVersion = 'Unknown';
  Map<String, dynamic>? _deviceInfo;
  String _bluetoothStatus = 'Not initialized';
  String _selectedDeviceId = '';
  int? _batteryLevel;
  final _timSdkPlugin = TimSdk();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      final platformVersion = await _timSdkPlugin.getPlatformVersion() ?? 'Unknown platform version';

      if (!mounted) return;

      setState(() {
        _platformVersion = platformVersion;
        _openToyVersion = 'OpenToy iOS Framework v1.0.0'; // 硬编码版本信息
        _deviceInfo = {'platform': 'iOS', 'systemVersion': 'Unknown', 'model': 'Unknown'};
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _platformVersion = 'Failed to get platform version: ${e.message}';
        _openToyVersion = 'OpenToy iOS Framework v1.0.0';
      });
    }
  }

  // 蓝牙功能方法
  Future<void> _initializeBluetooth() async {
    try {
      final result = await _timSdkPlugin.initializeBluetooth();
      if (!mounted) return;
      setState(() {
        _bluetoothStatus = result == true ? 'Initialized' : 'Failed to initialize';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _bluetoothStatus = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _startScan() async {
    try {
      final result = await _timSdkPlugin.startScan();
      if (!mounted) return;
      setState(() {
        _bluetoothStatus = result == true ? 'Scanning...' : 'Failed to start scan';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _bluetoothStatus = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _stopScan() async {
    try {
      final result = await _timSdkPlugin.stopScan();
      if (!mounted) return;
      setState(() {
        _bluetoothStatus = result == true ? 'Scan stopped' : 'Failed to stop scan';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _bluetoothStatus = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _disconnectFromDevice() async {
    if (_selectedDeviceId.isEmpty) return;

    try {
      final result = await _timSdkPlugin.disconnectFromDevice(_selectedDeviceId);
      if (!mounted) return;
      setState(() {
        _selectedDeviceId = '';
        _bluetoothStatus = result == true ? 'Disconnected' : 'Failed to disconnect';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _bluetoothStatus = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _readBatteryLevel() async {
    if (_selectedDeviceId.isEmpty) return;

    try {
      final result = await _timSdkPlugin.readBatteryLevel(_selectedDeviceId);
      if (!mounted) return;
      setState(() {
        _batteryLevel = result;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _batteryLevel = -1; // 表示错误
      });
    }
  }

  Future<void> _writeMotor(List<int> pwm) async {
    if (_selectedDeviceId.isEmpty) return;

    try {
      await _timSdkPlugin.writeMotor(_selectedDeviceId, pwm);
      if (!mounted) return;
      // 电机控制结果可以通过其他方式显示，比如状态栏或弹窗
      // 这里可以添加成功提示或其他UI反馈
    } on PlatformException {
      // 这里可以添加错误提示或其他UI反馈
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('TIM SDK Bluetooth Demo'), backgroundColor: Colors.blue),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Platform Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Platform: $_platformVersion'),
                      Text('OpenToy Version: $_openToyVersion'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OpenToy iOS Framework Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Framework Version: $_openToyVersion'),
                      if (_deviceInfo != null) ...[
                        Text('Platform: ${_deviceInfo!['platform']}'),
                        Text('System Version: ${_deviceInfo!['systemVersion']}'),
                        Text('Model: ${_deviceInfo!['model']}'),
                      ] else
                        const Text('Loading framework info...'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 蓝牙状态
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bluetooth Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Status: $_bluetoothStatus'),
                      if (_selectedDeviceId.isNotEmpty) Text('Connected Device: $_selectedDeviceId'),
                      if (_batteryLevel != null)
                        Text('Battery Level: ${_batteryLevel == -1 ? "Error" : "$_batteryLevel%"}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 蓝牙控制
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bluetooth Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(onPressed: _initializeBluetooth, child: const Text('Initialize')),
                          ElevatedButton(onPressed: _startScan, child: const Text('Start Scan')),
                          ElevatedButton(onPressed: _stopScan, child: const Text('Stop Scan')),
                        ],
                      ),
                      if (_selectedDeviceId.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(onPressed: _readBatteryLevel, child: const Text('Read Battery')),
                            ElevatedButton(onPressed: _disconnectFromDevice, child: const Text('Disconnect')),
                            ElevatedButton(onPressed: () => _writeMotor([50]), child: const Text('Motor 50%')),
                            ElevatedButton(onPressed: () => _writeMotor([0]), child: const Text('Motor Stop')),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
