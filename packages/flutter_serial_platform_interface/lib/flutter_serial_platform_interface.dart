import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterSerialPlatform extends PlatformInterface {
  FlutterSerialPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSerialPlatform? _instance;

  static FlutterSerialPlatform get instance {
    if (_instance == null) {
      throw UnimplementedError(
        'FlutterSerialPlatform instance has not been set.',
      );
    }
    return _instance!;
  }

  static set instance(FlutterSerialPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<SerialDevice>> listDevices();
  Future<SerialConnection> open(SerialDevice device, SerialConfig config);
}

class SerialDevice {
  final String id;
  final String name;

  const SerialDevice(this.id, this.name);
}

class SerialConfig {
  final int baudRate;

  const SerialConfig({this.baudRate = 115200});
}

abstract class SerialConnection {
  Stream<Uint8List> get input;
  Future<int> write(Uint8List data);
  Future<void> close();
}
