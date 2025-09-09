import 'package:bitcoin_sdk/bitcoin_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bitcoin SDK Tests', () {
    test('SDK info should be available', () {
      final info = BitcoinSdk.info;
      expect(info['name'], 'Bitcoin SDK for Flutter');
      expect(info['version'], '0.0.1');
      expect(info['description'], isNotEmpty);
    });

    test('Network info should be available', () {
      final networkInfo = BitcoinSdk.getNetworkInfo();
      expect(networkInfo, isNotEmpty);
      expect(networkInfo[BitcoinNetwork.mainnet], isNotNull);
      expect(networkInfo[BitcoinNetwork.testnet], isNotNull);
      expect(networkInfo[BitcoinNetwork.signet], isNotNull);
      expect(networkInfo[BitcoinNetwork.regtest], isNotNull);
    });

    test('BTC to Satoshis conversion', () {
      expect(BitcoinSdk.btcToSatoshis(1.0), 100000000);
      expect(BitcoinSdk.btcToSatoshis(0.5), 50000000);
      expect(BitcoinSdk.btcToSatoshis(0.00000001), 1);
    });

    test('Satoshis to BTC conversion', () {
      expect(BitcoinSdk.satoshisToBtc(100000000), 1.0);
      expect(BitcoinSdk.satoshisToBtc(50000000), 0.5);
      expect(BitcoinSdk.satoshisToBtc(1), 0.00000001);
    });

    test('Amount validation', () {
      expect(BitcoinSdk.isValidAmount(100000000), true);
      expect(BitcoinSdk.isValidAmount(0), true);
      expect(BitcoinSdk.isValidAmount(2100000000000000), true); // 21M BTC
    });

    test('BTC amount formatting', () {
      expect(BitcoinSdk.formatBtcAmount(100000000), '1.00000000');
      expect(BitcoinSdk.formatBtcAmount(50000000), '0.50000000');
      expect(BitcoinSdk.formatBtcAmount(1), '0.00000001');
    });

    test('BTC amount parsing', () {
      expect(BitcoinSdk.parseBtcAmount('1.0'), 100000000);
      expect(BitcoinSdk.parseBtcAmount('0.5'), 50000000);
      expect(BitcoinSdk.parseBtcAmount('0.00000001'), 1);
      expect(BitcoinSdk.parseBtcAmount('-1.0'), null);
      expect(BitcoinSdk.parseBtcAmount('invalid'), null);
    });

    test('Mnemonic validation', () {
      // Mnemônico válido para teste
      const validMnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      expect(BitcoinSdk.validateMnemonic(validMnemonic), true);

      // Mnemônico inválido
      expect(BitcoinSdk.validateMnemonic('invalid mnemonic'), false);
      expect(BitcoinSdk.validateMnemonic(''), false);
    });

    // Nota: Os testes de geração e restauração de carteira são comentados
    // pois dependem da biblioteca nativa compilada estar disponível
    /*
    test('Wallet generation', () {
      final wallet = BitcoinSdk.generateWallet(BitcoinNetwork.testnet);
      expect(wallet, isNotNull);
      expect(wallet!.address, isNotEmpty);
      expect(wallet.mnemonic, isNotEmpty);
      expect(wallet.publicKey, isNotEmpty);
      expect(wallet.privateKey, isNotEmpty);
    });

    test('Wallet restoration', () {
      const mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      final wallet = BitcoinSdk.restoreWalletFromMnemonic(mnemonic, BitcoinNetwork.testnet);
      expect(wallet, isNotNull);
      expect(wallet!.mnemonic, mnemonic);
    });
    */
  });
}
