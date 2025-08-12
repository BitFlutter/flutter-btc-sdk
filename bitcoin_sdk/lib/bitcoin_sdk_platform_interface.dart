import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bitcoin_sdk_method_channel.dart';

abstract class BitcoinSdkPlatform extends PlatformInterface {
  /// Constructs a BitcoinSdkPlatform.
  BitcoinSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static BitcoinSdkPlatform _instance = MethodChannelBitcoinSdk();

  /// The default instance of [BitcoinSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelBitcoinSdk].
  static BitcoinSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BitcoinSdkPlatform] when
  /// they register themselves.
  static set instance(BitcoinSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
