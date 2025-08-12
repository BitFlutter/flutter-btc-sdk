use bitcoin::{
    Network, PrivateKey, PublicKey, Address, Transaction, TxIn, TxOut, OutPoint, Txid,
    absolute::LockTime, Sequence, Witness, ScriptBuf, Amount
};
use bitcoin::secp256k1::{Secp256k1, Message, SecretKey};
use bitcoin::sighash::{SighashCache, EcdsaSighashType};
use std::str::FromStr;

#[derive(Debug)]
pub struct TransactionInput {
    pub txid: String,
    pub vout: u32,
    pub amount: u64, // em satoshis
    pub script_pubkey: String,
}

#[derive(Debug)]
pub struct TransactionOutput {
    pub address: String,
    pub amount: u64, // em satoshis
}

#[derive(Debug)]
pub struct UnsignedTransaction {
    pub transaction: Transaction,
    pub inputs_info: Vec<TransactionInput>,
}

pub fn create_transaction(
    inputs: Vec<TransactionInput>,
    outputs: Vec<TransactionOutput>,
    network: Network,
) -> Result<UnsignedTransaction, Box<dyn std::error::Error>> {
    let mut tx_inputs = Vec::new();
    let mut tx_outputs = Vec::new();

    // Criar inputs
    for input in &inputs {
        let txid = Txid::from_str(&input.txid)?;
        let outpoint = OutPoint::new(txid, input.vout);
        let tx_in = TxIn {
            previous_output: outpoint,
            script_sig: ScriptBuf::new(),
            sequence: Sequence::ENABLE_RBF_NO_LOCKTIME,
            witness: Witness::new(),
        };
        tx_inputs.push(tx_in);
    }

    // Criar outputs
    for output in &outputs {
        let address = Address::from_str(&output.address)?
            .require_network(network)?;
        let amount = Amount::from_sat(output.amount);
        let tx_out = TxOut {
            value: amount,
            script_pubkey: address.script_pubkey(),
        };
        tx_outputs.push(tx_out);
    }

    let transaction = Transaction {
        version: bitcoin::transaction::Version::TWO,
        lock_time: LockTime::ZERO,
        input: tx_inputs,
        output: tx_outputs,
    };

    Ok(UnsignedTransaction {
        transaction,
        inputs_info: inputs,
    })
}

pub fn sign_transaction(
    unsigned_tx: UnsignedTransaction,
    private_keys: Vec<&str>,
    network: Network,
) -> Result<Transaction, Box<dyn std::error::Error>> {
    let secp = Secp256k1::new();
    let mut signed_tx = unsigned_tx.transaction;

    for (i, input_info) in unsigned_tx.inputs_info.iter().enumerate() {
        if i >= private_keys.len() {
            return Err("Não há chaves privadas suficientes para assinar todos os inputs".into());
        }

        let private_key = PrivateKey::from_wif(private_keys[i])?;
        let public_key = PublicKey::from_private_key(&secp, &private_key);
        
        // Criar script_pubkey para P2WPKH
        let script_pubkey = ScriptBuf::from_hex(&input_info.script_pubkey)?;
        
        // Calcular sighash para SegWit v0
        let mut sighash_cache = SighashCache::new(&signed_tx);
        let sighash = sighash_cache.p2wpkh_signature_hash(
            i,
            &script_pubkey,
            Amount::from_sat(input_info.amount),
            EcdsaSighashType::All,
        )?;

        // Assinar
        let message = Message::from_digest_slice(sighash.as_byte_array())?;
        let signature = secp.sign_ecdsa(&message, &private_key.inner);
        let mut signature_bytes = signature.serialize_der().to_vec();
        signature_bytes.push(EcdsaSighashType::All as u8);

        // Criar witness para P2WPKH
        let witness = Witness::from_slice(&[&signature_bytes, &public_key.to_bytes()]);
        signed_tx.input[i].witness = witness;
    }

    Ok(signed_tx)
}

pub fn calculate_transaction_fee(
    inputs: &[TransactionInput],
    outputs: &[TransactionOutput],
    fee_rate: u64, // satoshis por vbyte
) -> Result<u64, Box<dyn std::error::Error>> {
    // Estimativa de tamanho da transação
    let input_count = inputs.len();
    let output_count = outputs.len();
    
    // Tamanho base da transação (versão + locktime + contadores)
    let base_size = 4 + 4 + 1 + 1; // versão + locktime + input_count + output_count
    
    // Tamanho dos inputs (P2WPKH)
    let input_size = input_count * (32 + 4 + 1 + 4); // txid + vout + script_sig_len + sequence
    
    // Tamanho dos outputs
    let output_size = output_count * (8 + 1 + 25); // value + script_len + script (assumindo P2WPKH)
    
    // Tamanho do witness (P2WPKH)
    let witness_size = input_count * (1 + 1 + 72 + 1 + 33); // stack_items + sig_len + sig + pubkey_len + pubkey
    
    // Calcular peso da transação (weight units)
    let non_witness_size = base_size + input_size + output_size;
    let total_weight = (non_witness_size * 4) + witness_size;
    let virtual_size = (total_weight + 3) / 4; // Arredondar para cima
    
    Ok(virtual_size as u64 * fee_rate)
}

pub fn estimate_transaction_size(input_count: usize, output_count: usize) -> usize {
    // Estimativa conservadora para transação P2WPKH
    let base_size = 10; // overhead da transação
    let input_size = input_count * 41; // input P2WPKH
    let output_size = output_count * 31; // output P2WPKH
    let witness_size = input_count * 107; // witness P2WPKH
    
    // Calcular vsize
    let non_witness_size = base_size + input_size + output_size;
    let total_weight = (non_witness_size * 4) + witness_size;
    (total_weight + 3) / 4
} 