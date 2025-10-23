// SPDX-License-Identifier: LGPL-3.0-only
//
// CRISP Voting App Prototype Circuit.
//
// This circuit is a prototype for CRISP, the voting app built on top of Enclave.

mod ciphertext_addition;
mod greco;

use ciphertext_addition::{
    check_ciphertext_addition_constraints, check_range_bounds, CiphertextAdditionParams,
};
use greco::{Greco, Params};
use polynomial::Polynomial;

// Main function for CRISP voting prototype.
fn main(
    ct_add_params: pub CiphertextAdditionParams<2048, 1>,
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

    let gammas = circuit.verify_correct_ciphertext_encryption();

    check_range_bounds::<2048, 1, 1>(ct_add_params);

    check_ciphertext_addition_constraints::<2048, 1>(
        ct_add_params,
        ct0is,
        ct1is,
        params.crypto_params().qis,
        gammas,
    );
}
