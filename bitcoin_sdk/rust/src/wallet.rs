use bitcoin::{Network, PrivateKey, PublicKey, Address};
use bitcoin::secp256k1::{Secp256k1, SecretKey};
use bip39::{Mnemonic, Language};
use std::str::FromStr;
use rand::rngs::OsRng;

#[derive(Debug)]
pub struct WalletData {
    pub private_key: String,
    pub public_key: String,
    pub address: String,
    pub mnemonic: String,
}

pub fn create_wallet(network: Network) -> Result<WalletData, Box<dyn std::error::Error>> {
    // Gerar entropia aleatória de 128 bits (12 palavras)
    let mut entropy = [0u8; 16];
    rand::RngCore::fill_bytes(&mut OsRng, &mut entropy);
    
    // Criar mnemônico a partir da entropia
    let mnemonic = Mnemonic::from_entropy_in(Language::English, &entropy)?;
    let mnemonic_str = mnemonic.to_string();

    // Criar chave privada a partir da seed
    let seed = mnemonic.to_seed("");
    let secp = Secp256k1::new();
    
    // Usar os primeiros 32 bytes da seed como chave privada
    let mut key_bytes = [0u8; 32];
    key_bytes.copy_from_slice(&seed[0..32]);
    let secret_key = SecretKey::from_slice(&key_bytes)?;
    
    let private_key = PrivateKey::new(secret_key, network);
    let public_key = PublicKey::from_private_key(&secp, &private_key);
    
    // Gerar endereço P2WPKH (Native SegWit)
    let address = Address::p2wpkh(&public_key, network)?;

    Ok(WalletData {
        private_key: private_key.to_wif(),
        public_key: public_key.to_string(),
        address: address.to_string(),
        mnemonic: mnemonic_str,
    })
}

pub fn restore_from_mnemonic(mnemonic_str: &str, network: Network) -> Result<WalletData, Box<dyn std::error::Error>> {
    // Parse do mnemônico
    let mnemonic = Mnemonic::parse_in_normalized(Language::English, mnemonic_str)?;
    
    // Criar chave privada a partir da seed
    let seed = mnemonic.to_seed("");
    let secp = Secp256k1::new();
    
    // Usar os primeiros 32 bytes da seed como chave privada
    let mut key_bytes = [0u8; 32];
    key_bytes.copy_from_slice(&seed[0..32]);
    let secret_key = SecretKey::from_slice(&key_bytes)?;
    
    let private_key = PrivateKey::new(secret_key, network);
    let public_key = PublicKey::from_private_key(&secp, &private_key);
    
    // Gerar endereço P2WPKH (Native SegWit)
    let address = Address::p2wpkh(&public_key, network)?;

    Ok(WalletData {
        private_key: private_key.to_wif(),
        public_key: public_key.to_string(),
        address: address.to_string(),
        mnemonic: mnemonic_str.to_string(),
    })
}

pub fn derive_address_at_index(
    mnemonic_str: &str, 
    network: Network, 
    _account: u32, 
    index: u32
) -> Result<WalletData, Box<dyn std::error::Error>> {
    let mnemonic = Mnemonic::parse_in_normalized(Language::English, mnemonic_str)?;
    let seed = mnemonic.to_seed("");
    let secp = Secp256k1::new();
    
    // Simular derivação usando hash da seed + index
    use std::collections::hash_map::DefaultHasher;
    use std::hash::{Hash, Hasher};
    
    let mut hasher = DefaultHasher::new();
    seed.hash(&mut hasher);
    index.hash(&mut hasher);
    let hash_result = hasher.finish();
    
    // Criar chave privada a partir do hash
    let mut key_bytes = [0u8; 32];
    key_bytes[0..8].copy_from_slice(&hash_result.to_be_bytes());
    key_bytes[8..16].copy_from_slice(&hash_result.to_le_bytes());
    key_bytes[16..24].copy_from_slice(&seed[0..8]);
    key_bytes[24..32].copy_from_slice(&seed[8..16]);
    
    let secret_key = SecretKey::from_slice(&key_bytes)?;
    let private_key = PrivateKey::new(secret_key, network);
    let public_key = PublicKey::from_private_key(&secp, &private_key);
    let address = Address::p2wpkh(&public_key, network)?;

    Ok(WalletData {
        private_key: private_key.to_wif(),
        public_key: public_key.to_string(),
        address: address.to_string(),
        mnemonic: mnemonic_str.to_string(),
    })
} 