/// 设备信息类
///
/// 包含智能玩具设备的详细信息，如MAC地址、硬件代码、固件版本等。
/// 这些信息通常在设备连接后通过GATT服务获取。
class TimDeviceInfo {
  /// MAC地址
  final String? mac;

  /// 变体代码
  final String? variantCode;

  /// 硬件代码
  final String? hardwareCode;

  /// 固件版本
  final String? firmwareVersion;

  /// 序列号
  final String? serialNumber;

  /// 电池电量（百分比）
  final int? battery;

  const TimDeviceInfo({
    this.mac,
    this.variantCode,
    this.hardwareCode,
    this.firmwareVersion,
    this.serialNumber,
    this.battery,
  });

  /// 检查设备信息是否为空
  ///
  /// 当所有字段都为null时返回true
  bool get isEmpty =>
      mac == null &&
      variantCode == null &&
      hardwareCode == null &&
      firmwareVersion == null &&
      serialNumber == null &&
      battery == null;

  /// 检查设备信息是否不为空
  ///
  /// 当至少有一个字段不为null时返回true
  bool get isNotEmpty => !isEmpty;

  /// 创建设备信息的副本并更新指定字段
  ///
  /// 参数：
  /// - [mac] 新的MAC地址，为null时保持原值
  /// - [variantCode] 新的变体代码，为null时保持原值
  /// - [hardwareCode] 新的硬件代码，为null时保持原值
  /// - [firmwareVersion] 新的固件版本，为null时保持原值
  /// - [serialNumber] 新的序列号，为null时保持原值
  /// - [battery] 新的电池电量，为null时保持原值
  ///
  /// 返回值：
  /// - [TimDeviceInfo] 更新后的设备信息对象
  TimDeviceInfo copyWith({
    String? mac,
    String? variantCode,
    String? hardwareCode,
    String? firmwareVersion,
    String? serialNumber,
    int? battery,
  }) {
    return TimDeviceInfo(
      mac: mac ?? this.mac,
      variantCode: variantCode ?? this.variantCode,
      hardwareCode: hardwareCode ?? this.hardwareCode,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      serialNumber: serialNumber ?? this.serialNumber,
      battery: battery ?? this.battery,
    );
  }

  /// 从Map创建DeviceInfo实例
  ///
  /// 参数：
  /// - [map] 包含设备信息的Map对象
  ///
  /// 返回值：
  /// - [TimDeviceInfo] 从Map创建的设备信息对象
  factory TimDeviceInfo.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return const TimDeviceInfo();
    }
    return TimDeviceInfo(
      mac: map['mac']?.toString(),
      variantCode: map['variantCode']?.toString(),
      hardwareCode: map['hardwareCode']?.toString(),
      firmwareVersion: map['firmwareVersion']?.toString(),
      serialNumber: map['serialNumber']?.toString(),
      battery: (map['battery'] as num?)?.toInt(),
    );
  }

  /// 将DeviceInfo转换为Map
  ///
  /// 参数：
  /// - [omitNulls] 是否忽略null值，默认为true
  ///
  /// 返回值：
  /// - [Map<String, dynamic>] 设备信息的Map表示
  Map<String, dynamic> toMap({bool omitNulls = true}) {
    final map = <String, dynamic>{
      'mac': mac,
      'variantCode': variantCode,
      'hardwareCode': hardwareCode,
      'firmwareVersion': firmwareVersion,
      'serialNumber': serialNumber,
      'battery': battery,
    };

    if (!omitNulls) {
      return map;
    }

    map.removeWhere((_, value) => value == null);
    return map;
  }
}

/// 蓝牙设备类
///
/// 表示一个蓝牙低功耗设备，包含设备的基本信息和连接状态。
/// 设备信息在扫描时和连接后可能会发生变化。
class TimDevice {
  /// 设备唯一标识符
  final String deviceId;

  /// 设备名称
  final String name;

  /// 信号强度（RSSI值）
  final int rssi;

  /// 是否已连接
  final bool isConnected;

  /// 设备详细信息
  final TimDeviceInfo deviceInfo;

  TimDevice({
    required this.deviceId,
    required this.name,
    required this.rssi,
    this.isConnected = false,
    TimDeviceInfo? deviceInfo,
  }) : deviceInfo = deviceInfo ?? const TimDeviceInfo();

  /// 从Map创建OpenToyDevice实例
  ///
  /// 参数：
  /// - [map] 包含设备信息的Map对象
  ///
  /// 返回值：
  /// - [TimDevice] 从Map创建的蓝牙设备对象
  factory TimDevice.fromMap(Map<String, dynamic> map) {
    return TimDevice(
      deviceId: map['deviceId'] ?? '',
      name: map['name'] ?? 'Unknown Device',
      rssi: map['rssi'] ?? 0,
      isConnected: map['isConnected'] ?? false,
      deviceInfo: map['deviceInfo'] != null
          ? TimDeviceInfo.fromMap(Map<String, dynamic>.from(map['deviceInfo']))
          : const TimDeviceInfo(),
    );
  }

  /// 创建蓝牙设备的副本并更新指定字段
  ///
  /// 参数：
  /// - [name] 新的设备名称，为null时保持原值
  /// - [rssi] 新的信号强度，为null时保持原值
  /// - [isConnected] 新的连接状态，为null时保持原值
  /// - [deviceInfo] 新的设备信息，为null时保持原值
  ///
  /// 返回值：
  /// - [TimDevice] 更新后的蓝牙设备对象
  TimDevice copyWith({String? name, int? rssi, bool? isConnected, TimDeviceInfo? deviceInfo}) {
    return TimDevice(
      deviceId: deviceId,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}
