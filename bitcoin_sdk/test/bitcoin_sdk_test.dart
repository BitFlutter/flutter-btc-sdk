import 'package:flutter_test/flutter_test.dart';
import 'package:bitcoin_sdk/bitcoin_sdk.dart';
import 'package:bitcoin_sdk/bitcoin_sdk_platform_interface.dart';
import 'package:bitcoin_sdk/bitcoin_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBitcoinSdkPlatform
    with MockPlatformInterfaceMixin
    implements BitcoinSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BitcoinSdkPlatform initialPlatform = BitcoinSdkPlatform.instance;

  test('$MethodChannelBitcoinSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBitcoinSdk>());
  });

  test('getPlatformVersion', () async {
    BitcoinSdk bitcoinSdkPlugin = BitcoinSdk();
    MockBitcoinSdkPlatform fakePlatform = MockBitcoinSdkPlatform();
    BitcoinSdkPlatform.instance = fakePlatform;

    expect(await bitcoinSdkPlugin.getPlatformVersion(), '42');
  });
}
