
import 'flutter_serial_web_platform_interface.dart';

class FlutterSerialWeb {
  Future<String?> getPlatformVersion() {
    return FlutterSerialWebPlatform.instance.getPlatformVersion();
  }
}
