// SPDX-License-Identifier: LGPL-3.0-only
//
// This file contains ciphertext addition verification for BFV ciphertexts.

use polynomial::Polynomial;

/// Parameters for ciphertext addition verification.
pub struct CiphertextAdditionParams<let D: u32, let L: u32> {
    pub old_ct0is: [Polynomial<D>; L],
    pub old_ct1is: [Polynomial<D>; L],
    pub sum_ct0is: [Polynomial<D>; L],
    pub sum_ct1is: [Polynomial<D>; L],
    pub sum_r0is: [Polynomial<D>; L],
    pub sum_r1is: [Polynomial<D>; L],
}

/// Verifies ciphertext addition constraints using Fiat-Shamir challenges.
///
/// # Arguments
/// * `ciphertext_addition_params` - Parameters for ciphertext addition verification.
/// * `ct0is`, `ct1is` - Ciphertext pairs to be added.
/// * `gammas` - Vector of challenge values [gamma_0, gamma_1, ..., gamma_{2L-1}]
pub fn check_ciphertext_addition_constraints<let D: u32, let L: u32>(
    p: CiphertextAdditionParams<D, L>,
    ct0is: [Polynomial<D>; L],
    ct1is: [Polynomial<D>; L],
    qis: [Field; L],
    gammas: Vec<Field>,
) {
    for i in 0..L {
        let gamma_i = gammas.get(i);

        let sum0 = p.sum_ct0is[i].eval(gamma_i);
        let sum1 = p.sum_ct1is[i].eval(gamma_i);

        let ct0 = ct0is[i].eval(gamma_i);
        let ct1 = ct1is[i].eval(gamma_i);

        let old0 = p.old_ct0is[i].eval(gamma_i);
        let old1 = p.old_ct1is[i].eval(gamma_i);

        let q_i = qis[i];

        // NEW: quotient polynomials evaluated at gamma
        let radd0 = p.sum_r0is[i].eval(gamma_i);
        let radd1 = p.sum_r1is[i].eval(gamma_i);

        // Core modular-equality constraints modulo qi
        assert(sum0 == ct0 + old0 + radd0 * q_i);
        assert(sum1 == ct1 + old1 + radd1 * q_i);
    }
}

#[test]
fn test_check_ciphertext_addition_constraints() {
    let ciphertext_addition_params = CiphertextAdditionParams {
        old_ct0is: [Polynomial::new([2, 3, 4]), Polynomial::new([1, 1, 1])],
        old_ct1is: [Polynomial::new([3, 4, 5]), Polynomial::new([1, 3, 2])],
        sum_ct0is: [Polynomial::new([8, 10, 12]), Polynomial::new([9, 11, 13])],
        sum_ct1is: [Polynomial::new([6, 7, 9]), Polynomial::new([8, 9, 7])],
        sum_r0is: [Polynomial::new([5, 6, 7]), Polynomial::new([3, 4, 5])],
        sum_r1is: [Polynomial::new([1, 2, 1]), Polynomial::new([2, 2, 2])],
    };

    let ct0is = [Polynomial::new([1, 1, 1]), Polynomial::new([2, 2, 2])];
    let ct1is = [Polynomial::new([2, 1, 3]), Polynomial::new([3, 2, 1])];

    let mut gammas = Vec::new();

    gammas.push(Field::from(2));
    gammas.push(Field::from(3));

    let qis = [Field::from(1), Field::from(2)];

    check_ciphertext_addition_constraints::<3, 2>(
        ciphertext_addition_params,
        ct0is,
        ct1is,
        qis,
        gammas,
    );
}
