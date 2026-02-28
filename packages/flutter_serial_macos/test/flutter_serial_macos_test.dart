import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_serial_macos/flutter_serial_macos.dart';
import 'package:flutter_serial_macos/flutter_serial_macos_platform_interface.dart';
import 'package:flutter_serial_macos/flutter_serial_macos_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSerialMacosPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSerialMacosPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSerialMacosPlatform initialPlatform = FlutterSerialMacosPlatform.instance;

  test('$MethodChannelFlutterSerialMacos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSerialMacos>());
  });

  test('getPlatformVersion', () async {
    FlutterSerialMacos flutterSerialMacosPlugin = FlutterSerialMacos();
    MockFlutterSerialMacosPlatform fakePlatform = MockFlutterSerialMacosPlatform();
    FlutterSerialMacosPlatform.instance = fakePlatform;

    expect(await flutterSerialMacosPlugin.getPlatformVersion(), '42');
  });
}
