// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_serial/flutter_serial.dart';
import 'package:flutter_serial_windows/flutter_serial_windows.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('listDevices returns a list', (WidgetTester tester) async {
    final FlutterSerialWindows plugin = FlutterSerialWindows();
    final List<SerialDevice> devices = await plugin.listDevices();
    expect(devices, isA<List<SerialDevice>>());
  });
}
