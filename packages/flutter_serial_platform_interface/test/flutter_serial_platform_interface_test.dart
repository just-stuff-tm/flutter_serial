import 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SerialDevice stores id and name', () {
    const SerialDevice device = SerialDevice('ttyUSB0', 'USB Serial');
    expect(device.id, 'ttyUSB0');
    expect(device.name, 'USB Serial');
  });
}
