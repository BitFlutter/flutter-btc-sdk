import 'package:bitcoin_sdk/bitcoin_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin SDK Demo',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const BitcoinSdkDemo(),
    );
  }
}

class BitcoinSdkDemo extends StatefulWidget {
  const BitcoinSdkDemo({super.key});

  @override
  State<BitcoinSdkDemo> createState() => _BitcoinSdkDemoState();
}

class _BitcoinSdkDemoState extends State<BitcoinSdkDemo> {
  BitcoinNetwork _selectedNetwork = BitcoinNetwork.testnet;
  BitcoinWalletData? _currentWallet;
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _btcAmountController = TextEditingController();
  String _statusMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSdkInfo();
  }

  void _loadSdkInfo() {
    final info = BitcoinSdk.info;
    setState(() {
      _statusMessage = 'Bitcoin SDK v${info['version']} carregado com sucesso!';
    });
  }

  Future<void> _generateWallet() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Gerando nova carteira...';
    });

    try {
      final wallet = BitcoinSdk.generateWallet(_selectedNetwork);
      setState(() {
        _currentWallet = wallet;
        _statusMessage = wallet != null
            ? 'Carteira gerada com sucesso!'
            : 'Erro ao gerar carteira';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreWallet() async {
    final mnemonic = _mnemonicController.text.trim();
    if (mnemonic.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor, insira um mnemônico';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Restaurando carteira...';
    });

    try {
      final wallet = BitcoinSdk.restoreWalletFromMnemonic(
        mnemonic,
        _selectedNetwork,
      );
      setState(() {
        _currentWallet = wallet;
        _statusMessage = wallet != null
            ? 'Carteira restaurada com sucesso!'
            : 'Erro ao restaurar carteira - verifique o mnemônico';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro: $e';
        _isLoading = false;
      });
    }
  }

  void _validateMnemonic() {
    final mnemonic = _mnemonicController.text.trim();
    if (mnemonic.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor, insira um mnemônico para validar';
      });
      return;
    }

    final isValid = BitcoinSdk.validateMnemonic(mnemonic);
    setState(() {
      _statusMessage = isValid ? 'Mnemônico válido ✓' : 'Mnemônico inválido ✗';
    });
  }

  void _validateAddress() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor, insira um endereço para validar';
      });
      return;
    }

    final isValid = BitcoinSdk.validateAddress(address, _selectedNetwork);
    setState(() {
      _statusMessage = isValid
          ? 'Endereço válido para ${_selectedNetwork.name} ✓'
          : 'Endereço inválido para ${_selectedNetwork.name} ✗';
    });
  }

  void _convertAmount() {
    final btcText = _btcAmountController.text.trim();
    if (btcText.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor, insira um valor em BTC';
      });
      return;
    }

    final satoshis = BitcoinSdk.parseBtcAmount(btcText);
    if (satoshis != null) {
      final formatted = BitcoinSdk.formatBtcAmount(satoshis);
      setState(() {
        _statusMessage =
            '$btcText BTC = $satoshis satoshis\nFormatado: $formatted BTC';
      });
    } else {
      setState(() {
        _statusMessage = 'Valor inválido';
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado para a área de transferência!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitcoin SDK Demo'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seleção de rede
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rede Bitcoin:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<BitcoinNetwork>(
                      value: _selectedNetwork,
                      isExpanded: true,
                      items: BitcoinNetwork.values.map((network) {
                        final info = BitcoinSdk.getNetworkInfo()[network]!;
                        return DropdownMenuItem(
                          value: network,
                          child: Text(
                            '${info['name']} ${info['isTestnet'] ? '(Testnet)' : ''}',
                          ),
                        );
                      }).toList(),
                      onChanged: (network) {
                        if (network != null) {
                          setState(() {
                            _selectedNetwork = network;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Geração de carteira
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gerar Nova Carteira',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _generateWallet,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Gerar Carteira'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Restauração de carteira
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurar Carteira',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _mnemonicController,
                      decoration: const InputDecoration(
                        hintText: 'Digite o mnemônico (12 ou 24 palavras)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _restoreWallet,
                          child: const Text('Restaurar'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _validateMnemonic,
                          child: const Text('Validar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Validação de endereço
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Validar Endereço',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: 'Digite o endereço Bitcoin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _validateAddress,
                      child: const Text('Validar Endereço'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Conversão de valores
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conversão BTC ↔ Satoshis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _btcAmountController,
                      decoration: const InputDecoration(
                        hintText: 'Digite o valor em BTC (ex: 0.001)',
                        border: OutlineInputBorder(),
                        suffixText: 'BTC',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _convertAmount,
                      child: const Text('Converter'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Exibição da carteira atual
            if (_currentWallet != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carteira Atual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildWalletInfo('Endereço', _currentWallet!.address),
                      _buildWalletInfo(
                        'Chave Pública',
                        _currentWallet!.publicKey,
                      ),
                      _buildWalletInfo(
                        'Mnemônico',
                        _currentWallet!.mnemonic,
                        sensitive: true,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Status
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage.isNotEmpty
                          ? _statusMessage
                          : 'Pronto para uso',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletInfo(
    String label,
    String value, {
    bool sensitive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _copyToClipboard(value),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      sensitive && value.length > 50
                          ? '${value.substring(0, 20)}...${value.substring(value.length - 20)}'
                          : value,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(Icons.copy, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mnemonicController.dispose();
    _addressController.dispose();
    _btcAmountController.dispose();
    super.dispose();
  }
}
