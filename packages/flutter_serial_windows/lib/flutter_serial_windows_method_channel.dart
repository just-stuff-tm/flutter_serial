import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_serial_windows_platform_interface.dart';

/// An implementation of [FlutterSerialWindowsPlatform] that uses method channels.
class MethodChannelFlutterSerialWindows extends FlutterSerialWindowsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_serial_windows');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
