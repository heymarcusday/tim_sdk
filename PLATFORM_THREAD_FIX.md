# 平台线程修复说明

## 问题描述

在iOS平台上，当使用TIM SDK时，可能会出现以下错误：

```
[ERROR:flutter/shell/common/shell.cc(1120)] The 'tim/events' channel sent a message from native to Flutter on a non-platform thread. Platform channel messages must be sent on the platform thread. Failure to do so may result in data loss or crashes, and must be fixed in the plugin or application code creating that channel.
```

## 问题原因

这个错误发生是因为在iOS原生代码中，蓝牙相关的回调方法（如CoreBluetooth的delegate方法）通常在后台线程上执行，但Flutter要求所有平台通道消息必须在主线程（平台线程）上发送。

## 解决方案

### iOS修复

在 `TimSdkPlugin.swift` 中，所有通过 `eventSink` 发送事件的方法都已修复，使用 `DispatchQueue.main.async` 确保在主线程上执行：

```swift
// 修复前
public func deviceDiscovered(_ device: [String: Any]) {
    if let eventSink = self.eventSink {
        let eventData: [String: Any] = [
            "type": "deviceDiscovered",
            "device": device
        ]
        eventSink(eventData)  // 可能在后台线程执行
    }
}

// 修复后
public func deviceDiscovered(_ device: [String: Any]) {
    DispatchQueue.main.async {  // 确保在主线程执行
        if let eventSink = self.eventSink {
            let eventData: [String: Any] = [
                "type": "deviceDiscovered",
                "device": device
            ]
            eventSink(eventData)
        }
    }
}
```

### 修复的方法列表

以下所有方法都已添加 `DispatchQueue.main.async` 包装：

1. `bluetoothStateChanged(_:)`
2. `deviceDiscovered(_:)`
3. `deviceConnected(_:deviceInfo:)`
4. `deviceDisconnected(_:error:)`
5. `deviceConnectionFailed(_:error:)`
6. `characteristicValueUpdated(_:characteristicId:data:)`
7. `characteristicReadFailed(_:characteristicId:error:)`
8. `characteristicWriteSuccess(_:characteristicId:)`
9. `characteristicWriteFailed(_:characteristicId:error:)`
10. `servicesDiscoveryFailed(_:error:)`
11. `characteristicsDiscoveryFailed(_:serviceId:error:)`

## 技术细节

### 为什么需要主线程？

Flutter的平台通道系统要求所有与Flutter的通信都必须在主线程上进行，这是因为：

1. **线程安全**: Flutter的UI更新必须在主线程上进行
2. **数据一致性**: 避免并发访问导致的数据不一致
3. **性能考虑**: 主线程上的操作可以更好地与Flutter引擎协调

### DispatchQueue.main.async 的作用

- `DispatchQueue.main.async` 确保代码块在主线程上异步执行
- 不会阻塞当前线程（通常是蓝牙回调线程）
- 保证事件发送的线程安全性

## 测试验证

修复后，以下操作应该不再产生平台线程错误：

1. 蓝牙初始化
2. 设备扫描和发现
3. 设备连接和断开
4. 特征值读写操作
5. 服务发现

## 注意事项

1. **性能影响**: 使用 `DispatchQueue.main.async` 会有轻微的性能开销，但对于事件发送来说是可接受的
2. **Android支持**: 当前修复主要针对iOS，Android端如需要类似修复，也需要确保事件发送在主线程上
3. **未来维护**: 添加新的事件发送方法时，务必使用 `DispatchQueue.main.async` 包装

## 相关文件

- `tim_sdk/ios/Classes/TimSdkPlugin.swift` - iOS平台实现
- `tim_sdk/lib/src/platform/method_channel.dart` - Flutter端平台通道实现

## 版本信息

- 修复版本: 1.0.0+
- 修复日期: 2024年
- 影响平台: iOS
