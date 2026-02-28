import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_serial_windows/flutter_serial_windows.dart';
import 'package:flutter_serial_windows/flutter_serial_windows_platform_interface.dart';
import 'package:flutter_serial_windows/flutter_serial_windows_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSerialWindowsPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSerialWindowsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSerialWindowsPlatform initialPlatform = FlutterSerialWindowsPlatform.instance;

  test('$MethodChannelFlutterSerialWindows is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSerialWindows>());
  });

  test('getPlatformVersion', () async {
    FlutterSerialWindows flutterSerialWindowsPlugin = FlutterSerialWindows();
    MockFlutterSerialWindowsPlatform fakePlatform = MockFlutterSerialWindowsPlatform();
    FlutterSerialWindowsPlatform.instance = fakePlatform;

    expect(await flutterSerialWindowsPlugin.getPlatformVersion(), '42');
  });
}
