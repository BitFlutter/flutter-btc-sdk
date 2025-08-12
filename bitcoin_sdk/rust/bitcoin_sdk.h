#ifndef BITCOIN_SDK_H
#define BITCOIN_SDK_H

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

    // Estrutura para representar uma carteira Bitcoin
    typedef struct
    {
        char *private_key;
        char *public_key;
        char *address;
        char *mnemonic;
    } BitcoinWallet;

    // Enums para tipos de rede
    typedef enum
    {
        BITCOIN_MAINNET = 0,
        BITCOIN_TESTNET = 1,
        BITCOIN_SIGNET = 2,
        BITCOIN_REGTEST = 3
    } NetworkType;

    // Funções de carteira
    BitcoinWallet *generate_wallet(int32_t network_type);
    BitcoinWallet *restore_wallet_from_mnemonic(const char *mnemonic_str, int32_t network_type);
    int32_t validate_mnemonic(const char *mnemonic_str);
    int32_t validate_address(const char *address_str, int32_t network_type);

    // Funções de limpeza de memória
    void free_wallet(BitcoinWallet *wallet);
    void free_c_string(char *s);

    // Funções de utilidade
    uint64_t btc_to_satoshis(double btc);
    double satoshis_to_btc(uint64_t satoshis);
    int32_t is_valid_amount(uint64_t satoshis);

    // Funções de transação (para implementação futura)
    // typedef struct TransactionInput TransactionInput;
    // typedef struct TransactionOutput TransactionOutput;
    // typedef struct UnsignedTransaction UnsignedTransaction;

#ifdef __cplusplus
}
#endif

#endif // BITCOIN_SDK_H