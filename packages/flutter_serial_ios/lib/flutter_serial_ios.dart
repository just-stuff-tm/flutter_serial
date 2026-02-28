import 'flutter_serial_ios_platform_interface.dart';

class FlutterSerialIos {
  Future<String?> getPlatformVersion() {
    return FlutterSerialIosPlatform.instance.getPlatformVersion();
  }
}
