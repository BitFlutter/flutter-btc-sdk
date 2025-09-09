use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let mut config = cbindgen::Config::default();
    config.language = cbindgen::Language::C;
    config.style = cbindgen::Style::Both;
    config.cpp_compat = true;
    config.header = Some(String::from("/* Bitcoin SDK FFI Header */"));
    
    cbindgen::generate_with_config(&crate_dir, config)
        .expect("Unable to generate bindings")
        .write_to_file("bitcoin_sdk.h");

    // Tell cargo to rerun this build script if the wrapper changes
    println!("cargo:rerun-if-changed=src/lib.rs");
    println!("cargo:rerun-if-changed=src/wallet.rs");
    println!("cargo:rerun-if-changed=src/transaction.rs");
    println!("cargo:rerun-if-changed=src/utils.rs");
} 