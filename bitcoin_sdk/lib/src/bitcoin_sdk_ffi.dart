import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

// Definições de estruturas FFI
final class BitcoinWalletStruct extends Struct {
  external Pointer<Utf8> privateKey;
  external Pointer<Utf8> publicKey;
  external Pointer<Utf8> address;
  external Pointer<Utf8> mnemonic;
}

// Definições de tipos de função FFI
typedef GenerateWalletNative =
    Pointer<BitcoinWalletStruct> Function(Int32 networkType);
typedef GenerateWalletDart =
    Pointer<BitcoinWalletStruct> Function(int networkType);

typedef RestoreWalletFromMnemonicNative =
    Pointer<BitcoinWalletStruct> Function(
      Pointer<Utf8> mnemonicStr,
      Int32 networkType,
    );
typedef RestoreWalletFromMnemonicDart =
    Pointer<BitcoinWalletStruct> Function(
      Pointer<Utf8> mnemonicStr,
      int networkType,
    );

typedef ValidateMnemonicNative = Int32 Function(Pointer<Utf8> mnemonicStr);
typedef ValidateMnemonicDart = int Function(Pointer<Utf8> mnemonicStr);

typedef ValidateAddressNative =
    Int32 Function(Pointer<Utf8> addressStr, Int32 networkType);
typedef ValidateAddressDart =
    int Function(Pointer<Utf8> addressStr, int networkType);

typedef FreeWalletNative = Void Function(Pointer<BitcoinWalletStruct> wallet);
typedef FreeWalletDart = void Function(Pointer<BitcoinWalletStruct> wallet);

typedef FreeCStringNative = Void Function(Pointer<Utf8> s);
typedef FreeCStringDart = void Function(Pointer<Utf8> s);

typedef BtcToSatoshisNative = Uint64 Function(Double btc);
typedef BtcToSatoshisDart = int Function(double btc);

typedef SatoshisToBtcNative = Double Function(Uint64 satoshis);
typedef SatoshisToBtcDart = double Function(int satoshis);

typedef IsValidAmountNative = Int32 Function(Uint64 satoshis);
typedef IsValidAmountDart = int Function(int satoshis);

/// Enums para tipos de rede Bitcoin
enum BitcoinNetwork {
  mainnet(0),
  testnet(1),
  signet(2),
  regtest(3);

  const BitcoinNetwork(this.value);
  final int value;
}

/// Classe principal para FFI do Bitcoin SDK
class BitcoinSdkFFI {
  static BitcoinSdkFFI? _instance;
  late final DynamicLibrary _dylib;
  late final GenerateWalletDart _generateWallet;
  late final RestoreWalletFromMnemonicDart _restoreWalletFromMnemonic;
  late final ValidateMnemonicDart _validateMnemonic;
  late final ValidateAddressDart _validateAddress;
  late final FreeWalletDart _freeWallet;
  late final FreeCStringDart _freeCString;
  late final BtcToSatoshisDart _btcToSatoshis;
  late final SatoshisToBtcDart _satoshisToBtc;
  late final IsValidAmountDart _isValidAmount;

  BitcoinSdkFFI._() {
    _dylib = _loadLibrary();
    _bindFunctions();
  }

  static BitcoinSdkFFI get instance {
    _instance ??= BitcoinSdkFFI._();
    return _instance!;
  }

  DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libbitcoin_sdk_rust.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libbitcoin_sdk_rust.so');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('bitcoin_sdk_rust.dll');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libbitcoin_sdk_rust.dylib');
    } else {
      throw UnsupportedError('Plataforma não suportada');
    }
  }

  void _bindFunctions() {
    _generateWallet = _dylib
        .lookup<NativeFunction<GenerateWalletNative>>('generate_wallet')
        .asFunction();

    _restoreWalletFromMnemonic = _dylib
        .lookup<NativeFunction<RestoreWalletFromMnemonicNative>>(
          'restore_wallet_from_mnemonic',
        )
        .asFunction();

    _validateMnemonic = _dylib
        .lookup<NativeFunction<ValidateMnemonicNative>>('validate_mnemonic')
        .asFunction();

    _validateAddress = _dylib
        .lookup<NativeFunction<ValidateAddressNative>>('validate_address')
        .asFunction();

    _freeWallet = _dylib
        .lookup<NativeFunction<FreeWalletNative>>('free_wallet')
        .asFunction();

    _freeCString = _dylib
        .lookup<NativeFunction<FreeCStringNative>>('free_c_string')
        .asFunction();

    _btcToSatoshis = _dylib
        .lookup<NativeFunction<BtcToSatoshisNative>>('btc_to_satoshis')
        .asFunction();

    _satoshisToBtc = _dylib
        .lookup<NativeFunction<SatoshisToBtcNative>>('satoshis_to_btc')
        .asFunction();

    _isValidAmount = _dylib
        .lookup<NativeFunction<IsValidAmountNative>>('is_valid_amount')
        .asFunction();
  }

  /// Gera uma nova carteira Bitcoin
  BitcoinWalletData? generateWallet(BitcoinNetwork network) {
    final walletPtr = _generateWallet(network.value);
    if (walletPtr.address == 0) return null;

    try {
      return _extractWalletData(walletPtr);
    } finally {
      _freeWallet(walletPtr);
    }
  }

  /// Restaura carteira a partir de mnemônico
  BitcoinWalletData? restoreWalletFromMnemonic(
    String mnemonic,
    BitcoinNetwork network,
  ) {
    final mnemonicPtr = mnemonic.toNativeUtf8();
    try {
      final walletPtr = _restoreWalletFromMnemonic(mnemonicPtr, network.value);
      if (walletPtr.address == 0) return null;

      try {
        return _extractWalletData(walletPtr);
      } finally {
        _freeWallet(walletPtr);
      }
    } finally {
      malloc.free(mnemonicPtr);
    }
  }

  /// Valida se um mnemônico é válido
  bool validateMnemonic(String mnemonic) {
    final mnemonicPtr = mnemonic.toNativeUtf8();
    try {
      return _validateMnemonic(mnemonicPtr) == 1;
    } finally {
      malloc.free(mnemonicPtr);
    }
  }

  /// Valida se um endereço é válido para a rede especificada
  bool validateAddress(String address, BitcoinNetwork network) {
    final addressPtr = address.toNativeUtf8();
    try {
      return _validateAddress(addressPtr, network.value) == 1;
    } finally {
      malloc.free(addressPtr);
    }
  }

  /// Converte BTC para satoshis
  int btcToSatoshis(double btc) {
    return _btcToSatoshis(btc);
  }

  /// Converte satoshis para BTC
  double satoshisToBtc(int satoshis) {
    return _satoshisToBtc(satoshis);
  }

  /// Verifica se um valor em satoshis é válido
  bool isValidAmount(int satoshis) {
    return _isValidAmount(satoshis) == 1;
  }

  BitcoinWalletData _extractWalletData(Pointer<BitcoinWalletStruct> walletPtr) {
    final wallet = walletPtr.ref;
    return BitcoinWalletData(
      privateKey: wallet.privateKey.toDartString(),
      publicKey: wallet.publicKey.toDartString(),
      address: wallet.address.toDartString(),
      mnemonic: wallet.mnemonic.toDartString(),
    );
  }
}

/// Classe para representar dados da carteira Bitcoin
class BitcoinWalletData {
  final String privateKey;
  final String publicKey;
  final String address;
  final String mnemonic;

  const BitcoinWalletData({
    required this.privateKey,
    required this.publicKey,
    required this.address,
    required this.mnemonic,
  });

  @override
  String toString() {
    return 'BitcoinWalletData(address: $address, publicKey: $publicKey)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BitcoinWalletData &&
        other.privateKey == privateKey &&
        other.publicKey == publicKey &&
        other.address == address &&
        other.mnemonic == mnemonic;
  }

  @override
  int get hashCode {
    return privateKey.hashCode ^
        publicKey.hashCode ^
        address.hashCode ^
        mnemonic.hashCode;
  }
}
