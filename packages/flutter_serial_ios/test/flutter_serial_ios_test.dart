import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_serial_ios/flutter_serial_ios.dart';
import 'package:flutter_serial_ios/flutter_serial_ios_platform_interface.dart';
import 'package:flutter_serial_ios/flutter_serial_ios_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSerialIosPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSerialIosPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSerialIosPlatform initialPlatform =
      FlutterSerialIosPlatform.instance;

  test('$MethodChannelFlutterSerialIos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSerialIos>());
  });

  test('getPlatformVersion', () async {
    FlutterSerialIos flutterSerialIosPlugin = FlutterSerialIos();
    MockFlutterSerialIosPlatform fakePlatform = MockFlutterSerialIosPlatform();
    FlutterSerialIosPlatform.instance = fakePlatform;

    expect(await flutterSerialIosPlugin.getPlatformVersion(), '42');
  });
}
