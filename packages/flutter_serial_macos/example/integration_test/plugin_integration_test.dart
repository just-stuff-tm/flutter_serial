// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_serial/flutter_serial.dart';
import 'package:flutter_serial_macos/flutter_serial_macos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('listDevices reports a list', (WidgetTester tester) async {
    final FlutterSerialMacos plugin = FlutterSerialMacos();
    final devices = await plugin.listDevices();
    expect(devices, isA<List<SerialDevice>>());
  });
}
