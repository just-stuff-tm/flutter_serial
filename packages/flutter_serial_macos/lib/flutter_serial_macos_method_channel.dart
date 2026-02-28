import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_serial_macos_platform_interface.dart';

/// An implementation of [FlutterSerialMacosPlatform] that uses method channels.
class MethodChannelFlutterSerialMacos extends FlutterSerialMacosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_serial_macos');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
