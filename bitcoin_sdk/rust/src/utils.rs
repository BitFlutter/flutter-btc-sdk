use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/// Converte uma String Rust para um ponteiro C char
pub fn string_to_c_char(s: &str) -> *mut c_char {
    match CString::new(s) {
        Ok(c_string) => c_string.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Libera memória de um ponteiro C char
pub fn free_c_char(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

/// Converte um ponteiro C char para String Rust
pub fn c_char_to_string(s: *const c_char) -> Result<String, std::str::Utf8Error> {
    let c_str = unsafe { CStr::from_ptr(s) };
    c_str.to_str().map(|s| s.to_string())
}

/// Converte satoshis para BTC (função interna)
pub fn satoshis_to_btc_internal(satoshis: u64) -> f64 {
    satoshis as f64 / 100_000_000.0
}

/// Converte BTC para satoshis (função interna)
pub fn btc_to_satoshis_internal(btc: f64) -> u64 {
    (btc * 100_000_000.0) as u64
}

/// Valida se um valor em satoshis é válido (função interna)
pub fn is_valid_amount_internal(satoshis: u64) -> bool {
    satoshis <= 21_000_000 * 100_000_000 // 21 milhões de BTC em satoshis
}

/// Formata um valor em satoshis como string BTC
pub fn format_btc_amount(satoshis: u64) -> String {
    let btc = satoshis_to_btc_internal(satoshis);
    format!("{:.8}", btc)
}

/// Parse de uma string BTC para satoshis
pub fn parse_btc_amount(btc_str: &str) -> Result<u64, Box<dyn std::error::Error>> {
    let btc: f64 = btc_str.parse()?;
    if btc < 0.0 {
        return Err("Valor não pode ser negativo".into());
    }
    let satoshis = btc_to_satoshis_internal(btc);
    if !is_valid_amount_internal(satoshis) {
        return Err("Valor excede o limite máximo de Bitcoin".into());
    }
    Ok(satoshis)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_satoshis_to_btc() {
        assert_eq!(satoshis_to_btc_internal(100_000_000), 1.0);
        assert_eq!(satoshis_to_btc_internal(50_000_000), 0.5);
        assert_eq!(satoshis_to_btc_internal(1), 0.00000001);
    }

    #[test]
    fn test_btc_to_satoshis() {
        assert_eq!(btc_to_satoshis_internal(1.0), 100_000_000);
        assert_eq!(btc_to_satoshis_internal(0.5), 50_000_000);
        assert_eq!(btc_to_satoshis_internal(0.00000001), 1);
    }

    #[test]
    fn test_is_valid_amount() {
        assert!(is_valid_amount_internal(100_000_000));
        assert!(is_valid_amount_internal(21_000_000 * 100_000_000));
        assert!(!is_valid_amount_internal(21_000_001 * 100_000_000));
    }

    #[test]
    fn test_parse_btc_amount() {
        assert_eq!(parse_btc_amount("1.0").unwrap(), 100_000_000);
        assert_eq!(parse_btc_amount("0.5").unwrap(), 50_000_000);
        assert!(parse_btc_amount("-1.0").is_err());
        assert!(parse_btc_amount("22000000.0").is_err());
    }
} 