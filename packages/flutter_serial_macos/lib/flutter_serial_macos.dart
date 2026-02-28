
import 'flutter_serial_macos_platform_interface.dart';

class FlutterSerialMacos {
  Future<String?> getPlatformVersion() {
    return FlutterSerialMacosPlatform.instance.getPlatformVersion();
  }
}
