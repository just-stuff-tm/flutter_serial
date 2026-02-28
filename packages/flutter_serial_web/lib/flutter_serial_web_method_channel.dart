import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_serial_web_platform_interface.dart';

/// An implementation of [FlutterSerialWebPlatform] that uses method channels.
class MethodChannelFlutterSerialWeb extends FlutterSerialWebPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_serial_web');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
