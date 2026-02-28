import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_serial_windows_method_channel.dart';

abstract class FlutterSerialWindowsPlatform extends PlatformInterface {
  /// Constructs a FlutterSerialWindowsPlatform.
  FlutterSerialWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSerialWindowsPlatform _instance = MethodChannelFlutterSerialWindows();

  /// The default instance of [FlutterSerialWindowsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSerialWindows].
  static FlutterSerialWindowsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSerialWindowsPlatform] when
  /// they register themselves.
  static set instance(FlutterSerialWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
