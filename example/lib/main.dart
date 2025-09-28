import 'package:flutter/material.dart';
import 'package:tim_sdk/tim_sdk.dart';
import 'home_page.dart';
import 'battery_examples.dart';
import 'battery_monitor_example.dart';
import 'device_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4E5CF5), brightness: Brightness.dark);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      listTileTheme: ListTileThemeData(textColor: colorScheme.onSurface, iconColor: colorScheme.onSurfaceVariant),
      textTheme: ThemeData(
        brightness: Brightness.dark,
      ).textTheme.apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface),
    );

    return MaterialApp(title: 'TIM SDK - OpenToy 蓝牙控制演示', theme: theme, home: const FactoryHomePage());
  }
}

class FactoryHomePage extends StatelessWidget {
  const FactoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TIM SDK 演示'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TIM SDK - OpenToy 蓝牙控制演示',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '选择要测试的功能模块',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    title: '蓝牙设备管理',
                    description: '扫描、连接、断开设备',
                    icon: Icons.bluetooth,
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage())),
                  ),
                  _buildFeatureCard(
                    context,
                    title: '电池电量示例',
                    description: '直接读取 vs 事件监听',
                    icon: Icons.battery_std,
                    color: Colors.orange,
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const BatteryExamples())),
                  ),
                  _buildFeatureCard(
                    context,
                    title: '电池监控示例',
                    description: '定期监控电池电量变化',
                    icon: Icons.monitor_heart,
                    color: Colors.purple,
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const BatteryMonitorExample())),
                  ),
                  _buildFeatureCard(
                    context,
                    title: '设备详情控制',
                    description: '设备信息、电池、电机控制',
                    icon: Icons.settings,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeviceDetailPage(
                          deviceId: 'demo_device',
                          deviceName: '演示设备',
                          initialIsConnected: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
