
import 'flutter_serial_android_platform_interface.dart';

class FlutterSerialAndroid {
  Future<String?> getPlatformVersion() {
    return FlutterSerialAndroidPlatform.instance.getPlatformVersion();
  }
}
