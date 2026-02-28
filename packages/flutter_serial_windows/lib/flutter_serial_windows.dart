import 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';

import 'src/serial_windows_ffi.dart';

class FlutterSerialWindows extends FlutterSerialPlatform {
  @override
  Future<List<SerialDevice>> listDevices() async {
    final List<String> devices = scanDevices();
    return devices.map((String d) => SerialDevice(d, d)).toList();
  }

  @override
  Future<SerialConnection> open(
    SerialDevice device,
    SerialConfig config,
  ) async {
    return openSerial(device.id, config.baudRate);
  }
}

void registerWith() {
  FlutterSerialPlatform.instance = FlutterSerialWindows();
}
