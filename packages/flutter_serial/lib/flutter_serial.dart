export 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';
import 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';

/// Public API surface.
/// This is the ONLY entrypoint developers should use.
class FlutterSerial {
  const FlutterSerial();

  Future<List<SerialDevice>> listDevices() {
    return FlutterSerialPlatform.instance.listDevices();
  }

  Future<SerialConnection> open(
    SerialDevice device,
    SerialConfig config,
  ) {
    return FlutterSerialPlatform.instance.open(device, config);
  }
}
