import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_serial_android/flutter_serial_android.dart';
import 'package:flutter_serial_android/flutter_serial_android_platform_interface.dart';
import 'package:flutter_serial_android/flutter_serial_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSerialAndroidPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSerialAndroidPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSerialAndroidPlatform initialPlatform = FlutterSerialAndroidPlatform.instance;

  test('$MethodChannelFlutterSerialAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSerialAndroid>());
  });

  test('getPlatformVersion', () async {
    FlutterSerialAndroid flutterSerialAndroidPlugin = FlutterSerialAndroid();
    MockFlutterSerialAndroidPlatform fakePlatform = MockFlutterSerialAndroidPlatform();
    FlutterSerialAndroidPlatform.instance = fakePlatform;

    expect(await flutterSerialAndroidPlugin.getPlatformVersion(), '42');
  });
}
