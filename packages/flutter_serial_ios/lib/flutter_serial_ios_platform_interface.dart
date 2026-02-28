import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_serial_ios_method_channel.dart';

abstract class FlutterSerialIosPlatform extends PlatformInterface {
  /// Constructs a FlutterSerialIosPlatform.
  FlutterSerialIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSerialIosPlatform _instance = MethodChannelFlutterSerialIos();

  /// The default instance of [FlutterSerialIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSerialIos].
  static FlutterSerialIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSerialIosPlatform] when
  /// they register themselves.
  static set instance(FlutterSerialIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
