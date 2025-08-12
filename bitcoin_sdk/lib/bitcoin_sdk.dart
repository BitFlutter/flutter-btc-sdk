library;

import 'src/bitcoin_sdk_ffi.dart';

export 'src/bitcoin_sdk_ffi.dart';

/// Classe principal do Bitcoin SDK para Flutter
///
/// Esta biblioteca permite integrar funcionalidades Bitcoin em aplicativos Flutter,
/// incluindo geração de carteiras, validação de endereços, e gestão de chaves privadas.
class BitcoinSdk {
  static final BitcoinSdkFFI _ffi = BitcoinSdkFFI.instance;

  /// Gera uma nova carteira Bitcoin com mnemônico
  ///
  /// [network] - Rede Bitcoin a ser usada (mainnet, testnet, signet, regtest)
  ///
  /// Retorna [BitcoinWalletData] com chave privada, chave pública, endereço e mnemônico,
  /// ou null em caso de erro.
  ///
  /// Exemplo:
  /// ```dart
  /// final wallet = BitcoinSdk.generateWallet(BitcoinNetwork.testnet);
  /// if (wallet != null) {
  ///   print('Endereço: ${wallet.address}');
  ///   print('Mnemônico: ${wallet.mnemonic}');
  /// }
  /// ```
  static BitcoinWalletData? generateWallet(BitcoinNetwork network) {
    return _ffi.generateWallet(network);
  }

  /// Restaura uma carteira Bitcoin a partir de um mnemônico
  ///
  /// [mnemonic] - Frase mnemônica de 12 ou 24 palavras
  /// [network] - Rede Bitcoin a ser usada
  ///
  /// Retorna [BitcoinWalletData] com os dados da carteira restaurada,
  /// ou null em caso de erro ou mnemônico inválido.
  ///
  /// Exemplo:
  /// ```dart
  /// final mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
  /// final wallet = BitcoinSdk.restoreWalletFromMnemonic(mnemonic, BitcoinNetwork.testnet);
  /// if (wallet != null) {
  ///   print('Carteira restaurada: ${wallet.address}');
  /// }
  /// ```
  static BitcoinWalletData? restoreWalletFromMnemonic(
    String mnemonic,
    BitcoinNetwork network,
  ) {
    return _ffi.restoreWalletFromMnemonic(mnemonic, network);
  }

  /// Valida se um mnemônico é válido segundo BIP39
  ///
  /// [mnemonic] - Frase mnemônica a ser validada
  ///
  /// Retorna true se o mnemônico for válido, false caso contrário.
  ///
  /// Exemplo:
  /// ```dart
  /// final isValid = BitcoinSdk.validateMnemonic("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about");
  /// print('Mnemônico válido: $isValid');
  /// ```
  static bool validateMnemonic(String mnemonic) {
    return _ffi.validateMnemonic(mnemonic);
  }

  /// Valida se um endereço Bitcoin é válido para a rede especificada
  ///
  /// [address] - Endereço Bitcoin a ser validado
  /// [network] - Rede Bitcoin para validação
  ///
  /// Retorna true se o endereço for válido para a rede, false caso contrário.
  ///
  /// Exemplo:
  /// ```dart
  /// final isValid = BitcoinSdk.validateAddress("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4", BitcoinNetwork.mainnet);
  /// print('Endereço válido: $isValid');
  /// ```
  static bool validateAddress(String address, BitcoinNetwork network) {
    return _ffi.validateAddress(address, network);
  }

  /// Converte um valor em BTC para satoshis
  ///
  /// [btc] - Valor em BTC (pode ter decimais)
  ///
  /// Retorna o valor em satoshis (inteiro).
  ///
  /// Exemplo:
  /// ```dart
  /// final satoshis = BitcoinSdk.btcToSatoshis(0.001); // 100000 satoshis
  /// print('$satoshis satoshis');
  /// ```
  static int btcToSatoshis(double btc) {
    return _ffi.btcToSatoshis(btc);
  }

  /// Converte um valor em satoshis para BTC
  ///
  /// [satoshis] - Valor em satoshis
  ///
  /// Retorna o valor em BTC (com decimais).
  ///
  /// Exemplo:
  /// ```dart
  /// final btc = BitcoinSdk.satoshisToBtc(100000); // 0.001 BTC
  /// print('$btc BTC');
  /// ```
  static double satoshisToBtc(int satoshis) {
    return _ffi.satoshisToBtc(satoshis);
  }

  /// Verifica se um valor em satoshis é válido
  ///
  /// [satoshis] - Valor em satoshis a ser validado
  ///
  /// Retorna true se o valor estiver dentro dos limites válidos do Bitcoin.
  ///
  /// Exemplo:
  /// ```dart
  /// final isValid = BitcoinSdk.isValidAmount(100000);
  /// print('Valor válido: $isValid');
  /// ```
  static bool isValidAmount(int satoshis) {
    return _ffi.isValidAmount(satoshis);
  }

  /// Formata um valor em satoshis como string BTC
  ///
  /// [satoshis] - Valor em satoshis
  /// [decimals] - Número de casas decimais (padrão: 8)
  ///
  /// Retorna string formatada representando o valor em BTC.
  ///
  /// Exemplo:
  /// ```dart
  /// final formatted = BitcoinSdk.formatBtcAmount(150000000); // "1.50000000"
  /// print('Valor formatado: $formatted BTC');
  /// ```
  static String formatBtcAmount(int satoshis, {int decimals = 8}) {
    final btc = satoshisToBtc(satoshis);
    return btc.toStringAsFixed(decimals);
  }

  /// Parse de uma string BTC para satoshis
  ///
  /// [btcString] - String representando valor em BTC
  ///
  /// Retorna o valor em satoshis ou null se a string for inválida.
  ///
  /// Exemplo:
  /// ```dart
  /// final satoshis = BitcoinSdk.parseBtcAmount("0.001"); // 100000
  /// if (satoshis != null) {
  ///   print('$satoshis satoshis');
  /// }
  /// ```
  static int? parseBtcAmount(String btcString) {
    try {
      final btc = double.parse(btcString);
      if (btc < 0) return null;
      final satoshis = btcToSatoshis(btc);
      return isValidAmount(satoshis) ? satoshis : null;
    } catch (e) {
      return null;
    }
  }

  /// Obtém informações sobre as redes Bitcoin disponíveis
  ///
  /// Retorna um mapa com informações sobre cada rede.
  static Map<BitcoinNetwork, Map<String, dynamic>> getNetworkInfo() {
    return {
      BitcoinNetwork.mainnet: {
        'name': 'Bitcoin Mainnet',
        'description': 'Rede principal do Bitcoin',
        'addressPrefix': ['1', '3', 'bc1'],
        'isTestnet': false,
      },
      BitcoinNetwork.testnet: {
        'name': 'Bitcoin Testnet',
        'description': 'Rede de teste do Bitcoin',
        'addressPrefix': ['m', 'n', '2', 'tb1'],
        'isTestnet': true,
      },
      BitcoinNetwork.signet: {
        'name': 'Bitcoin Signet',
        'description': 'Rede Signet para desenvolvimento',
        'addressPrefix': ['tb1'],
        'isTestnet': true,
      },
      BitcoinNetwork.regtest: {
        'name': 'Bitcoin Regtest',
        'description': 'Rede local para desenvolvimento',
        'addressPrefix': ['bcrt1'],
        'isTestnet': true,
      },
    };
  }

  /// Versão do SDK
  static const String version = '0.0.1';

  /// Informações sobre o SDK
  static Map<String, String> get info => {
    'name': 'Bitcoin SDK for Flutter',
    'version': version,
    'description':
        'Biblioteca completa para integração Bitcoin em aplicativos Flutter usando Rust via FFI',
    'repository': 'https://github.com/your-username/flutter-btc-sdk',
  };
}
