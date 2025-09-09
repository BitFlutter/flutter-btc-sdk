use std::ffi::CStr;
use std::os::raw::c_char;
use bitcoin::{Network, Address};
use bip39::{Mnemonic, Language};
use std::str::FromStr;

mod wallet;
mod utils;

use wallet::*;
use utils::*;

/// Estrutura para representar uma carteira Bitcoin
#[repr(C)]
pub struct BitcoinWallet {
    pub private_key: *mut c_char,
    pub public_key: *mut c_char,
    pub address: *mut c_char,
    pub mnemonic: *mut c_char,
}

/// Gera uma nova carteira Bitcoin com mnemônico
#[no_mangle]
pub extern "C" fn generate_wallet(network_type: i32) -> *mut BitcoinWallet {
    let network = match network_type {
        0 => Network::Bitcoin,
        1 => Network::Testnet,
        2 => Network::Signet,
        3 => Network::Regtest,
        _ => Network::Testnet,
    };

    match create_wallet(network) {
        Ok(wallet_data) => {
            let wallet = Box::new(BitcoinWallet {
                private_key: string_to_c_char(&wallet_data.private_key),
                public_key: string_to_c_char(&wallet_data.public_key),
                address: string_to_c_char(&wallet_data.address),
                mnemonic: string_to_c_char(&wallet_data.mnemonic),
            });
            Box::into_raw(wallet)
        }
        Err(_) => std::ptr::null_mut(),
    }
}

/// Restaura carteira a partir de mnemônico
#[no_mangle]
pub extern "C" fn restore_wallet_from_mnemonic(
    mnemonic_str: *const c_char,
    network_type: i32,
) -> *mut BitcoinWallet {
    let mnemonic_cstr = unsafe { CStr::from_ptr(mnemonic_str) };
    let mnemonic_string = match mnemonic_cstr.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let network = match network_type {
        0 => Network::Bitcoin,
        1 => Network::Testnet,
        2 => Network::Signet,
        3 => Network::Regtest,
        _ => Network::Testnet,
    };

    match restore_from_mnemonic(mnemonic_string, network) {
        Ok(wallet_data) => {
            let wallet = Box::new(BitcoinWallet {
                private_key: string_to_c_char(&wallet_data.private_key),
                public_key: string_to_c_char(&wallet_data.public_key),
                address: string_to_c_char(&wallet_data.address),
                mnemonic: string_to_c_char(&wallet_data.mnemonic),
            });
            Box::into_raw(wallet)
        }
        Err(_) => std::ptr::null_mut(),
    }
}

/// Valida se um mnemônico é válido
#[no_mangle]
pub extern "C" fn validate_mnemonic(mnemonic_str: *const c_char) -> i32 {
    let mnemonic_cstr = unsafe { CStr::from_ptr(mnemonic_str) };
    let mnemonic_string = match mnemonic_cstr.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };

    match Mnemonic::parse_in_normalized(Language::English, mnemonic_string) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

/// Valida se um endereço Bitcoin é válido
#[no_mangle]
pub extern "C" fn validate_address(address_str: *const c_char, network_type: i32) -> i32 {
    let address_cstr = unsafe { CStr::from_ptr(address_str) };
    let address_string = match address_cstr.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };

    let network = match network_type {
        0 => Network::Bitcoin,
        1 => Network::Testnet,
        2 => Network::Signet,
        3 => Network::Regtest,
        _ => Network::Testnet,
    };

    match Address::from_str(address_string) {
        Ok(addr) => {
            if addr.is_valid_for_network(network) {
                1
            } else {
                0
            }
        }
        Err(_) => 0,
    }
}

/// Converte BTC para satoshis
#[no_mangle]
pub extern "C" fn btc_to_satoshis(btc: f64) -> u64 {
    btc_to_satoshis_internal(btc)
}

/// Converte satoshis para BTC
#[no_mangle]
pub extern "C" fn satoshis_to_btc(satoshis: u64) -> f64 {
    satoshis_to_btc_internal(satoshis)
}

/// Verifica se um valor em satoshis é válido
#[no_mangle]
pub extern "C" fn is_valid_amount(satoshis: u64) -> i32 {
    if is_valid_amount_internal(satoshis) {
        1
    } else {
        0
    }
}

/// Libera memória alocada para a carteira
#[no_mangle]
pub extern "C" fn free_wallet(wallet: *mut BitcoinWallet) {
    if !wallet.is_null() {
        unsafe {
            let wallet = Box::from_raw(wallet);
            free_c_char(wallet.private_key);
            free_c_char(wallet.public_key);
            free_c_char(wallet.address);
            free_c_char(wallet.mnemonic);
        }
    }
}

/// Libera string C
#[no_mangle]
pub extern "C" fn free_c_string(s: *mut c_char) {
    free_c_char(s);
} 