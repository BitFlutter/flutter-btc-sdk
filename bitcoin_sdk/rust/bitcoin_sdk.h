/* Bitcoin SDK FFI Header */

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Estrutura para representar uma carteira Bitcoin
 */
typedef struct BitcoinWallet {
  char *private_key;
  char *public_key;
  char *address;
  char *mnemonic;
} BitcoinWallet;

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

/**
 * Gera uma nova carteira Bitcoin com mnemônico
 */
struct BitcoinWallet *generate_wallet(int32_t network_type);

/**
 * Restaura carteira a partir de mnemônico
 */
struct BitcoinWallet *restore_wallet_from_mnemonic(const char *mnemonic_str, int32_t network_type);

/**
 * Valida se um mnemônico é válido
 */
int32_t validate_mnemonic(const char *mnemonic_str);

/**
 * Valida se um endereço Bitcoin é válido
 */
int32_t validate_address(const char *address_str, int32_t network_type);

/**
 * Converte BTC para satoshis
 */
uint64_t btc_to_satoshis(double btc);

/**
 * Converte satoshis para BTC
 */
double satoshis_to_btc(uint64_t satoshis);

/**
 * Verifica se um valor em satoshis é válido
 */
int32_t is_valid_amount(uint64_t satoshis);

/**
 * Libera memória alocada para a carteira
 */
void free_wallet(struct BitcoinWallet *wallet);

/**
 * Libera string C
 */
void free_c_string(char *s);

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus
