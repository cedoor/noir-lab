// SPDX-License-Identifier: LGPL-3.0-only
//
// This file demonstrates the use of the Greco crate for BFV public key encryption verification
//
// This circuit verifies that ciphertext components (ct0, ct1) are correctly computed
// from public key components (pk0, pk1) and encryption randomness using the BFV scheme.

mod greco;
mod polynomial;
mod safe;
mod greco_add;

use greco::{Greco, Params};
use polynomial::Polynomial;
use greco_add::{verify_add_component, verify_add_ciphertext, verify_add_ciphertext_rns};

// Main function for testing Greco Addition
// Simple test with scalar values
fn main(
    // Public: ciphertext components to add
    c1_t0: pub Field, c1_t1: pub Field,
    c2_t0: pub Field, c2_t1: pub Field,
    csum_t0: pub Field, csum_t1: pub Field,
    qi: pub Field,
    
    // Private: carry/recentering terms
    r1_t0: Field, r1_t1: Field
) {
    // Verify the addition using Greco relations
    verify_add_ciphertext(
        c1_t0, c1_t1,
        c2_t0, c2_t1,
        csum_t0, csum_t1,
        qi,
        r1_t0, r1_t1
    );
}

// Alternative main function for the original Greco encryption verification
// (commented out for now)
/*
fn main_greco(
    params: pub Params<2048, 1>,
    pk0is: pub [Polynomial<2048>; 1],
    pk1is: pub [Polynomial<2048>; 1], 
    ct0is: pub [Polynomial<2048>; 1],
    ct1is: pub [Polynomial<2048>; 1],
    u: Polynomial<2048>,
    e0: Polynomial<2048>,
    e1: Polynomial<2048>,
    k1: Polynomial<2048>,
    r1is: [Polynomial<4095>; 1],
    r2is: [Polynomial<2047>; 1],
    p1is: [Polynomial<4095>; 1],
    p2is: [Polynomial<2047>; 1],
) {
    // Create a Greco circuit instance with all the required parameters
    let circuit = Greco::new(
        params,
        pk0is,
        pk1is,
        ct0is,
        ct1is,
        u,
        e0,
        e1,
        k1,
        r1is,
        r2is,
        p1is,
        p2is,
    );
    
    // Additional constraint: k1 must be binary (0 or 1) at the highest coefficient
    // This ensures proper message encoding
    assert(
        0
            == k1.coefficients[2048 - 1]
                * (params.crypto_params().q_mod_t - k1.coefficients[2048 - 1]),
    );

    // Verify that the ciphertext was correctly formed
    circuit.verify_correct_ciphertext_encryption();
}
*/

#[test]
fn test_greco_compilation() {
    // This test ensures that the Greco crate imports and basic types work correctly
    // Note: This doesn't test actual encryption verification due to the complexity
    // of generating valid BFV parameters, but it validates the circuit compiles
    
    // Create a simple polynomial with zeros for testing purposes
    let test_poly: Polynomial<4> = Polynomial {
        coefficients: [0, 0, 0, 0]
    };
    
    // Basic assertion to ensure the polynomial structure works
    assert(test_poly.coefficients[0] == 0);
    assert(test_poly.coefficients.len() == 4);
}

#[test]
fn test_greco_addition_basic() {
    // Test basic Greco addition verification
    // Example: c1 = 430, c2 = 25, qi = 503
    // pre_sum = 455, reduced = -48 (since 455 - 503 = -48)
    // So r1 = 1 (since 455 = -48 + 1 * 503)
    
    let c1 = 430;
    let c2 = 25; 
    let c_sum = -48; // 430 + 25 - 503 = -48
    let qi = 503;
    let r1 = 1; // carry term
    
    // This should pass
    verify_add_component(c1, c2, c_sum, qi, r1);
}

#[test] 
fn test_greco_addition_ciphertext() {
    // Test addition of ciphertext pair (ct0, ct1)
    let c1_t0 = 430;
    let c1_t1 = -120;
    let c2_t0 = 25;
    let c2_t1 = 80;
    
    let qi = 503;
    
    // Compute expected sums
    let csum_t0 = -48; // (430 + 25) - 503 = -48
    let csum_t1 = -40; // (-120 + 80) = -40 (no carry needed)
    
    let r1_t0 = 1; // carry for t0
    let r1_t1 = 0; // no carry for t1
    
    verify_add_ciphertext(
        c1_t0, c1_t1,
        c2_t0, c2_t1, 
        csum_t0, csum_t1,
        qi,
        r1_t0, r1_t1
    );
}

#[test]
fn test_greco_addition_rns() {
    // Test RNS (multiple moduli) addition
    let c1_t0 = [430, 200];
    let c1_t1 = [-120, 150];
    let c2_t0 = [25, 100];
    let c2_t1 = [80, -50];
    
    let qis = [503, 257]; // Two CRT moduli
    
    // For qi = 503: same as previous test
    // For qi = 257: (200 + 100) = 300, no reduction needed, (150 + (-50)) = 100
    let csum_t0 = [-48, 43]; // 300 - 257 = 43, so r1 = 1 for second modulus
    let csum_t1 = [-40, 100];
    
    let r1_t0 = [1, 1]; // carry for both moduli for t0
    let r1_t1 = [0, 0]; // no carry for t1
    
    verify_add_ciphertext_rns(
        c1_t0, c1_t1,
        c2_t0, c2_t1,
        csum_t0, csum_t1,
        qis,
        r1_t0, r1_t1
    );
}
