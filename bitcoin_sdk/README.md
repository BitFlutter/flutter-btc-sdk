# Bitcoin SDK para Flutter

[![pub package](https://img.shields.io/pub/v/bitcoin_sdk.svg)](https://pub.dev/packages/bitcoin_sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Uma biblioteca completa para integração Bitcoin em aplicativos Flutter, desenvolvida com Rust via FFI (Foreign Function Interface) para máxima performance e segurança.

## 🚀 Características

- ✅ **Geração de Carteiras**: Crie novas carteiras Bitcoin com mnemônicos BIP39
- ✅ **Restauração de Carteiras**: Restaure carteiras existentes usando mnemônicos
- ✅ **Validação**: Valide endereços Bitcoin e mnemônicos
- ✅ **Múltiplas Redes**: Suporte para Mainnet, Testnet, Signet e Regtest
- ✅ **Conversões**: Converta entre BTC e satoshis
- ✅ **Segurança**: Implementado em Rust para máxima segurança
- ✅ **Performance**: FFI nativo para alta performance
- ✅ **Multiplataforma**: iOS, Android, macOS, Windows, Linux

## 🛠️ Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  bitcoin_sdk: ^0.0.1
```

Execute:

```bash
flutter pub get
```

### Pré-requisitos

Para compilar a biblioteca nativa, você precisa ter instalado:

1. **Rust**: Instale via [rustup.rs](https://rustup.rs/)
2. **Flutter**: Versão 3.3.0 ou superior
3. **Android NDK** (para Android): Configure `ANDROID_NDK_HOME`
4. **Xcode** (para iOS/macOS): Instale via App Store

## 📱 Uso Básico

### Importar a biblioteca

```dart
import 'package:bitcoin_sdk/bitcoin_sdk.dart';
```

### Gerar uma nova carteira

```dart
// Gerar carteira para testnet
final wallet = BitcoinSdk.generateWallet(BitcoinNetwork.testnet);

if (wallet != null) {
  print('Endereço: ${wallet.address}');
  print('Chave Pública: ${wallet.publicKey}');
  print('Mnemônico: ${wallet.mnemonic}');
  // NUNCA imprima a chave privada em produção!
  print('Chave Privada: ${wallet.privateKey}');
}
```

### Restaurar carteira a partir de mnemônico

```dart
const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
final wallet = BitcoinSdk.restoreWalletFromMnemonic(
  mnemonic, 
  BitcoinNetwork.testnet
);

if (wallet != null) {
  print('Carteira restaurada: ${wallet.address}');
}
```

### Validar mnemônico

```dart
const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
final isValid = BitcoinSdk.validateMnemonic(mnemonic);
print('Mnemônico válido: $isValid'); // true
```

### Validar endereço Bitcoin

```dart
const address = "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4";
final isValid = BitcoinSdk.validateAddress(address, BitcoinNetwork.mainnet);
print('Endereço válido: $isValid'); // true
```

### Conversões BTC ↔ Satoshis

```dart
// BTC para satoshis
final satoshis = BitcoinSdk.btcToSatoshis(0.001); // 100000
print('0.001 BTC = $satoshis satoshis');

// Satoshis para BTC
final btc = BitcoinSdk.satoshisToBtc(100000); // 0.001
print('100000 satoshis = $btc BTC');

// Formatação
final formatted = BitcoinSdk.formatBtcAmount(150000000); // "1.50000000"
print('Formatado: $formatted BTC');

// Parse de string
final parsed = BitcoinSdk.parseBtcAmount("0.001"); // 100000
print('Parsed: $parsed satoshis');
```

## 🌐 Redes Bitcoin

A biblioteca suporta todas as principais redes Bitcoin:

```dart
// Rede principal (produção)
BitcoinNetwork.mainnet

// Rede de teste
BitcoinNetwork.testnet

// Rede Signet (desenvolvimento)
BitcoinNetwork.signet

// Rede local (desenvolvimento)
BitcoinNetwork.regtest

// Obter informações sobre as redes
final networkInfo = BitcoinSdk.getNetworkInfo();
print(networkInfo[BitcoinNetwork.mainnet]);
```

## 🏗️ Compilação

### Automatizada

Execute o script de build:

```bash
# macOS/Linux
./scripts/build_rust.sh

# Windows (PowerShell)
.\scripts\build_rust.ps1
```

### Manual

1. Navegue até o diretório `rust/`:
```bash
cd rust/
```

2. Compile para sua plataforma:
```bash
# Para desenvolvimento local
cargo build --release

# Para Android (requer NDK)
cargo build --release --target aarch64-linux-android

# Para iOS
cargo build --release --target aarch64-apple-ios
```

## 📁 Estrutura do Projeto

```
bitcoin_sdk/
├── lib/                    # Código Dart
│   ├── src/               # Implementações internas
│   │   └── bitcoin_sdk_ffi.dart
│   └── bitcoin_sdk.dart   # API pública
├── rust/                  # Código Rust
│   ├── src/
│   │   ├── lib.rs        # Interface FFI
│   │   ├── wallet.rs     # Funcionalidades de carteira
│   │   ├── transaction.rs # Funcionalidades de transação
│   │   └── utils.rs      # Utilidades
│   ├── Cargo.toml
│   └── build.rs
├── scripts/               # Scripts de build
│   └── build_rust.sh
├── example/              # App de exemplo
└── README.md
```

## 🔒 Segurança

### Boas Práticas

1. **Nunca armazene chaves privadas em texto plano**
2. **Use armazenamento seguro** (Keychain no iOS, Keystore no Android)
3. **Valide sempre os inputs do usuário**
4. **Use apenas redes de teste durante desenvolvimento**
5. **Implemente backup seguro dos mnemônicos**

### Exemplo de Armazenamento Seguro

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureWalletStorage {
  static const _storage = FlutterSecureStorage();
  
  // Salvar mnemônico de forma segura
  static Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(key: 'wallet_mnemonic', value: mnemonic);
  }
  
  // Recuperar mnemônico
  static Future<String?> getMnemonic() async {
    return await _storage.read(key: 'wallet_mnemonic');
  }
  
  // Deletar dados sensíveis
  static Future<void> clearWallet() async {
    await _storage.delete(key: 'wallet_mnemonic');
  }
}
```

## 🧪 Testes

Execute os testes:

```bash
# Testes Dart
flutter test

# Testes Rust
cd rust/
cargo test
```

## 📚 Exemplos

Veja o diretório `example/` para um aplicativo completo demonstrando todas as funcionalidades.

Para executar o exemplo:

```bash
cd example/
flutter run
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📋 Roadmap

- [ ] Suporte a transações Bitcoin completas
- [ ] Integração com APIs de blockchain
- [ ] Suporte a Lightning Network
- [ ] Carteiras multi-assinatura
- [ ] Suporte a Taproot
- [ ] Integração com hardware wallets

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- [rust-bitcoin](https://github.com/rust-bitcoin/rust-bitcoin) - Biblioteca Bitcoin em Rust
- [bip39](https://crates.io/crates/bip39) - Implementação BIP39
- [secp256k1](https://crates.io/crates/secp256k1) - Criptografia de curva elíptica
- Comunidade Flutter e Rust

## 📞 Suporte

- 📧 Email: support@bitcoinsdk.dev
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/flutter-btc-sdk/issues)
- 💬 Discussões: [GitHub Discussions](https://github.com/your-username/flutter-btc-sdk/discussions)

---

**⚠️ Aviso**: Esta biblioteca é para fins educacionais e de desenvolvimento. Sempre teste extensivamente antes de usar em produção com Bitcoin real.

