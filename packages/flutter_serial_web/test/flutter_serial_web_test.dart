import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_serial_web/flutter_serial_web.dart';
import 'package:flutter_serial_web/flutter_serial_web_platform_interface.dart';
import 'package:flutter_serial_web/flutter_serial_web_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSerialWebPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSerialWebPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSerialWebPlatform initialPlatform = FlutterSerialWebPlatform.instance;

  test('$MethodChannelFlutterSerialWeb is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSerialWeb>());
  });

  test('getPlatformVersion', () async {
    FlutterSerialWeb flutterSerialWebPlugin = FlutterSerialWeb();
    MockFlutterSerialWebPlatform fakePlatform = MockFlutterSerialWebPlatform();
    FlutterSerialWebPlatform.instance = fakePlatform;

    expect(await flutterSerialWebPlugin.getPlatformVersion(), '42');
  });
}
