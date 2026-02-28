import 'package:flutter_serial/flutter_serial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SerialConfig exposes baud rate', (WidgetTester tester) async {
    const SerialConfig config = SerialConfig(baudRate: 9600);
    expect(config.baudRate, 9600);
  });
}
