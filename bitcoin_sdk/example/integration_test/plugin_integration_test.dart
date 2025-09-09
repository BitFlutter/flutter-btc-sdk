// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:bitcoin_sdk/bitcoin_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bitcoin SDK basic functionality test', (
    WidgetTester tester,
  ) async {
    // Testa a validação de mnemônico
    final validMnemonic =
        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    final isValidMnemonic = BitcoinSdk.validateMnemonic(validMnemonic);
    expect(isValidMnemonic, true);

    // Testa conversão BTC para satoshis
    final satoshis = BitcoinSdk.btcToSatoshis(0.001);
    expect(satoshis, 100000);

    // Testa conversão satoshis para BTC
    final btc = BitcoinSdk.satoshisToBtc(100000);
    expect(btc, 0.001);

    // Verifica informações do SDK
    expect(BitcoinSdk.version, isNotEmpty);
    expect(BitcoinSdk.info['name'], isNotEmpty);
  });
}
