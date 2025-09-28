import 'package:flutter_test/flutter_test.dart';
import 'package:tim_sdk/tim_sdk.dart';
import 'package:tim_sdk/tim_sdk_platform_interface.dart';
import 'package:tim_sdk/tim_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTimSdkPlatform
    with MockPlatformInterfaceMixin
    implements TimSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TimSdkPlatform initialPlatform = TimSdkPlatform.instance;

  test('$MethodChannelTimSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTimSdk>());
  });

  test('getPlatformVersion', () async {
    TimSdk timSdkPlugin = TimSdk();
    MockTimSdkPlatform fakePlatform = MockTimSdkPlatform();
    TimSdkPlatform.instance = fakePlatform;

    expect(await timSdkPlugin.getPlatformVersion(), '42');
  });
}
