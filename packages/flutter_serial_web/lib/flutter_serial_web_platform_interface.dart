import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_serial_web_method_channel.dart';

abstract class FlutterSerialWebPlatform extends PlatformInterface {
  /// Constructs a FlutterSerialWebPlatform.
  FlutterSerialWebPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSerialWebPlatform _instance = MethodChannelFlutterSerialWeb();

  /// The default instance of [FlutterSerialWebPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSerialWeb].
  static FlutterSerialWebPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSerialWebPlatform] when
  /// they register themselves.
  static set instance(FlutterSerialWebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
