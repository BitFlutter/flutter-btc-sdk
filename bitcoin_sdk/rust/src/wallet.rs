use bitcoin::{Network, PrivateKey, PublicKey, Address};
use bitcoin::secp256k1::{Secp256k1, SecretKey};
use bip39::{Mnemonic, Language};
use bip32::{ExtendedPrivateKey, DerivationPath};
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
    // Gerar mnemônico
    let mut rng = OsRng;
    let mnemonic = Mnemonic::generate_in_with(&mut rng, Language::English, 12)?;
    let mnemonic_str = mnemonic.to_string();

    // Derivar chave mestra
    let seed = mnemonic.to_seed("");
    let secp = Secp256k1::new();
    let master_key = ExtendedPrivateKey::new_master(network, &seed)?;

    // Derivar chave para o caminho padrão m/84'/0'/0'/0/0 (Native SegWit)
    let derivation_path = match network {
        Network::Bitcoin => DerivationPath::from_str("m/84'/0'/0'/0/0")?,
        _ => DerivationPath::from_str("m/84'/1'/0'/0/0")?, // Testnet
    };
    
    let derived_key = master_key.derive_priv(&secp, &derivation_path)?;
    let private_key = PrivateKey::new(derived_key.private_key, network);
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
    let mnemonic = Mnemonic::parse(mnemonic_str)?;
    
    // Derivar chave mestra
    let seed = mnemonic.to_seed("");
    let secp = Secp256k1::new();
    let master_key = ExtendedPrivateKey::new_master(network, &seed)?;

    // Derivar chave para o caminho padrão m/84'/0'/0'/0/0 (Native SegWit)
    let derivation_path = match network {
        Network::Bitcoin => DerivationPath::from_str("m/84'/0'/0'/0/0")?,
        _ => DerivationPath::from_str("m/84'/1'/0'/0/0")?, // Testnet
    };
    
    let derived_key = master_key.derive_priv(&secp, &derivation_path)?;
    let private_key = PrivateKey::new(derived_key.private_key, network);
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
    account: u32, 
    index: u32
) -> Result<WalletData, Box<dyn std::error::Error>> {
    let mnemonic = Mnemonic::parse(mnemonic_str)?;
    let seed = mnemonic.to_seed("");
    let secp = Secp256k1::new();
    let master_key = ExtendedPrivateKey::new_master(network, &seed)?;

    // Caminho de derivação personalizado
    let coin_type = match network {
        Network::Bitcoin => 0,
        _ => 1, // Testnet
    };
    
    let derivation_path = DerivationPath::from_str(&format!("m/84'/{}'/{}'/{}/{}", coin_type, account, 0, index))?;
    let derived_key = master_key.derive_priv(&secp, &derivation_path)?;
    let private_key = PrivateKey::new(derived_key.private_key, network);
    let public_key = PublicKey::from_private_key(&secp, &private_key);
    let address = Address::p2wpkh(&public_key, network)?;

    Ok(WalletData {
        private_key: private_key.to_wif(),
        public_key: public_key.to_string(),
        address: address.to_string(),
        mnemonic: mnemonic_str.to_string(),
    })
} 