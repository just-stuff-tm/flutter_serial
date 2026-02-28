import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_serial_android_method_channel.dart';

abstract class FlutterSerialAndroidPlatform extends PlatformInterface {
  /// Constructs a FlutterSerialAndroidPlatform.
  FlutterSerialAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSerialAndroidPlatform _instance =
      MethodChannelFlutterSerialAndroid();

  /// The default instance of [FlutterSerialAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSerialAndroid].
  static FlutterSerialAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSerialAndroidPlatform] when
  /// they register themselves.
  static set instance(FlutterSerialAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
