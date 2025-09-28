# TIM

A Flutter plugin that provides Bluetooth Low Energy functionality for connecting to OpenToy devices.

## Features

- Bluetooth Low Energy device discovery and connection
- Motor control commands
- Battery level reading
- Device state management

## Setup

### iOS Configuration

Add the following permissions to your `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to OpenToy devices for controlling motors and reading battery levels.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to connect to OpenToy devices for controlling motors and reading battery levels.</string>
```

### Android Configuration

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## Usage

```dart
import 'package:tim/tim.dart';

// Initialize Bluetooth
await TimSdk.initializeBluetooth();

// Start scanning for devices
await TimSdk.startScan();

// Connect to a device
await TimSdk.connectToDevice(deviceId);

// Read battery level
int batteryLevel = await TimSdk.readBatteryLevel(deviceId);

// Control motor
await TimSdk.writeMotor(deviceId, pwm: 100);
```

## Getting Started

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

