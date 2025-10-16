// SPDX-License-Identifier: LGPL-3.0-only
//
// This file demonstrates BFV ciphertext addition verification
//
// This circuit verifies that two BFV ciphertexts are correctly added together
// using the additive homomorphism property of the BFV scheme.

mod ciphertext_addition;

use ciphertext_addition::add_ciphertexts;

use greco::{Greco, Params};
use polynomial::Polynomial;

// Main function for testing BFV ciphertext addition
// Verifies addition of two ciphertext pairs (ct0, ct1)
fn main(
    params: pub Params<2048, 1>,
    pk0is: pub [Polynomial<2048>; 1],
    pk1is: pub [Polynomial<2048>; 1],
    ct0is: pub [Polynomial<2048>; 1],
    ct1is: pub [Polynomial<2048>; 1],
    ct0js: pub [Polynomial<2048>; 1],
    ct1js: pub [Polynomial<2048>; 1],
    u: Polynomial<2048>,
    e0: Polynomial<2048>,
    e1: Polynomial<2048>,
    k1: Polynomial<2048>,
    r1is: [Polynomial<4095>; 1],
    r2is: [Polynomial<2047>; 1],
    p1is: [Polynomial<4095>; 1],
    p2is: [Polynomial<2047>; 1],
) -> pub ([Polynomial<2048>; 1], [Polynomial<2048>; 1]) {
    let circuit: Greco<2048, 1, 54, 54, 5, 5, 20, 20, 54, 16, 54> = Greco::new(
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

    assert(
        0
            == k1.coefficients[2048 - 1]
                * (params.crypto_params().q_mod_t - k1.coefficients[2048 - 1]),
    );

    circuit.verify_correct_ciphertext_encryption();

    // --- Homomorphic addition: C_out = C1 + C2 (component-wise) ---
    // Inputs: (ct0is, ct1is) and (ct0js, ct1js)
    // Output: (sum_ct0is, sum_ct1is)
    let (sum_ct0is, sum_ct1is) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Return public outputs (ciphertext of the sum)
    (sum_ct0is, sum_ct1is)
}
