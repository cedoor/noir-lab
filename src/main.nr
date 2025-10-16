// SPDX-License-Identifier: LGPL-3.0-only
//
// This file demonstrates BFV ciphertext addition verification
//
// This circuit verifies that two BFV ciphertexts are correctly added together
// using the additive homomorphism property of the BFV scheme.

mod ciphertext_addition;

use ciphertext_addition::{verify_add_ciphertext, verify_add_ciphertext_rns, verify_add_component};
use polynomial::Polynomial;

// Main function for testing BFV ciphertext addition
// Verifies addition of two ciphertext pairs (ct0, ct1)
fn main(
    // Public: ciphertext components to add
    c1_t0: pub Field,
    c1_t1: pub Field,
    c2_t0: pub Field,
    c2_t1: pub Field,
    csum_t0: pub Field,
    csum_t1: pub Field,
    qi: pub Field,
    // Private: carry/recentering terms
    r1_t0: Field,
    r1_t1: Field,
) {
    // Verify the addition using BFV homomorphic addition
    verify_add_ciphertext(
        c1_t0,
        c1_t1,
        c2_t0,
        c2_t1,
        csum_t0,
        csum_t1,
        qi,
        r1_t0,
        r1_t1,
    );
}

#[test]
fn test_polynomial_compilation() {
    // This test ensures that the polynomial crate imports and basic types work correctly
    // Basic validation that the circuit compiles with polynomial dependencies

    // Create a simple polynomial with zeros for testing purposes
    let test_poly: Polynomial<4> = Polynomial { coefficients: [0, 0, 0, 0] };

    // Basic assertion to ensure the polynomial structure works
    assert(test_poly.coefficients[0] == 0);
    assert(test_poly.coefficients.len() == 4);
}

#[test]
fn test_bfv_addition_basic() {
    // Test basic BFV ciphertext addition verification
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
fn test_bfv_addition_ciphertext() {
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
        c1_t0,
        c1_t1,
        c2_t0,
        c2_t1,
        csum_t0,
        csum_t1,
        qi,
        r1_t0,
        r1_t1,
    );
}

#[test]
fn test_bfv_addition_rns() {
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
        c1_t0,
        c1_t1,
        c2_t0,
        c2_t1,
        csum_t0,
        csum_t1,
        qis,
        r1_t0,
        r1_t1,
    );
}
