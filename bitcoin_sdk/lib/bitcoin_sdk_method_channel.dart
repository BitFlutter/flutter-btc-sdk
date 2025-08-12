import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bitcoin_sdk_platform_interface.dart';

/// An implementation of [BitcoinSdkPlatform] that uses method channels.
class MethodChannelBitcoinSdk extends BitcoinSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bitcoin_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
