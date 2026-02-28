import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_serial_macos_method_channel.dart';

abstract class FlutterSerialMacosPlatform extends PlatformInterface {
  /// Constructs a FlutterSerialMacosPlatform.
  FlutterSerialMacosPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSerialMacosPlatform _instance = MethodChannelFlutterSerialMacos();

  /// The default instance of [FlutterSerialMacosPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSerialMacos].
  static FlutterSerialMacosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSerialMacosPlatform] when
  /// they register themselves.
  static set instance(FlutterSerialMacosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
