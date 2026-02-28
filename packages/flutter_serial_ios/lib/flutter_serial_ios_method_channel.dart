import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_serial_ios_platform_interface.dart';

/// An implementation of [FlutterSerialIosPlatform] that uses method channels.
class MethodChannelFlutterSerialIos extends FlutterSerialIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_serial_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
