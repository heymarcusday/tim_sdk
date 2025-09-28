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
  String _operationResult = '';
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
      final openToyVersion = await _timSdkPlugin.getOpenToyVersion() ?? 'Unknown OpenToy version';
      final deviceInfo = await _timSdkPlugin.getOpenToyDeviceInfo();

      if (!mounted) return;

      setState(() {
        _platformVersion = platformVersion;
        _openToyVersion = openToyVersion;
        _deviceInfo = deviceInfo;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _platformVersion = 'Failed to get platform version: ${e.message}';
        _openToyVersion = 'Failed to get OpenToy version: ${e.message}';
      });
    }
  }

  Future<void> _performOperation(String operation) async {
    try {
      final result = await _timSdkPlugin.performOpenToyOperation(operation);
      if (!mounted) return;
      setState(() {
        _operationResult = result ?? 'No result';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _operationResult = 'Error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('TIM SDK + OpenToy iOS Demo'), backgroundColor: Colors.blue),
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
                        'Device Information (from OpenToy iOS)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_deviceInfo != null) ...[
                        Text('Platform: ${_deviceInfo!['platform']}'),
                        Text('System Version: ${_deviceInfo!['systemVersion']}'),
                        Text('Model: ${_deviceInfo!['model']}'),
                        Text('Name: ${_deviceInfo!['name']}'),
                        Text('Identifier: ${_deviceInfo!['identifier']}'),
                      ] else
                        const Text('Loading device info...'),
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
                      const Text('OpenToy Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(onPressed: () => _performOperation('hello'), child: const Text('Hello')),
                          ElevatedButton(onPressed: () => _performOperation('version'), child: const Text('Version')),
                          ElevatedButton(
                            onPressed: () => _performOperation('device'),
                            child: const Text('Device Info'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_operationResult.isNotEmpty) ...[
                        const Text('Operation Result:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                          child: Text(_operationResult),
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
