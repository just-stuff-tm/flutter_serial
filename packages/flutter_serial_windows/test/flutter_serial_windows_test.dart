import 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';
import 'package:flutter_serial_windows/flutter_serial_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registerWith installs FlutterSerialWindows instance', () {
    registerWith();
    expect(FlutterSerialPlatform.instance, isA<FlutterSerialWindows>());
  });
}
