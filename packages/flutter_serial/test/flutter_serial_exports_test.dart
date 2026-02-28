import 'package:flutter_serial/flutter_serial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports SerialConfig API', () {
    const config = SerialConfig(baudRate: 9600);
    expect(config.baudRate, 9600);
  });
}
