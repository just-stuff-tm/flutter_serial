
import 'flutter_serial_windows_platform_interface.dart';

class FlutterSerialWindows {
  Future<String?> getPlatformVersion() {
    return FlutterSerialWindowsPlatform.instance.getPlatformVersion();
  }
}
