import 'package:flutter_serial_linux/flutter_serial_linux.dart';
import 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registerWith installs FlutterSerialLinux instance', () {
    registerWith();
    expect(FlutterSerialPlatform.instance, isA<FlutterSerialLinux>());
  });
}
