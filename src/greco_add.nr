// SPDX-License-Identifier: LGPL-3.0-only
//
// Greco Addition Module
//
// This module implements zero-knowledge proofs for correct addition of BFV ciphertexts
// using the Greco relations. It verifies that the sum of two ciphertexts is correctly
// computed according to the BFV additive homomorphism.
//
// The core relation enforced is:
// pre_sum = c1 + c2 = c_sum + r1 * qi
//
// Where:
// - c1, c2 are the input ciphertext components
// - c_sum is the reduced sum component
// - r1 is the carry/recentering term
// - qi is the modulus for the i-th CRT basis
//
// For n=2 addends, the bound constraint is |r1| <= 1, i.e., r1 in {-1, 0, 1}

use crate::polynomial::Polynomial;

/// Verifies the correct addition of a single ciphertext component modulo qi.
///
/// This function enforces the Greco relation for addition:
/// c1 + c2 = c_sum + r1 * qi
///
/// And the bound constraint for n=2 addends: r1 in {-1, 0, 1}
///
/// # Arguments
/// * `c1` - First ciphertext component
/// * `c2` - Second ciphertext component
/// * `c_sum` - Reduced sum component
/// * `qi` - CRT modulus
/// * `r1` - Carry/recentering term (witness or public)
pub fn verify_add_component(c1: Field, c2: Field, c_sum: Field, qi: Field, r1: Field) {
    // Compute pre-reduction sum
    let pre_sum = c1 + c2;

    // Enforce Greco relation: pre_sum = c_sum + r1 * qi
    assert_eq(pre_sum, c_sum + r1 * qi);

    // Enforce bound constraint for n=2 addends: r1 in {-1, 0, 1}
    // Using cubic constraint: r1 * (r1 - 1) * (r1 + 1) = 0
    assert_eq(r1 * (r1 - 1) * (r1 + 1), 0);
}

/// Verifies the correct addition of a ciphertext pair (ct0, ct1) for a single CRT modulus.
///
/// This function applies the component verification to both ciphertext components.
///
/// # Arguments
/// * `c1_t0`, `c1_t1` - First ciphertext components (ct0, ct1)
/// * `c2_t0`, `c2_t1` - Second ciphertext components (ct0, ct1)
/// * `csum_t0`, `csum_t1` - Sum ciphertext components (ct0, ct1)
/// * `qi` - CRT modulus
/// * `r1_t0`, `r1_t1` - Carry terms for each component
pub fn verify_add_ciphertext(
    c1_t0: Field,
    c1_t1: Field,
    c2_t0: Field,
    c2_t1: Field,
    csum_t0: Field,
    csum_t1: Field,
    qi: Field,
    r1_t0: Field,
    r1_t1: Field,
) {
    // Verify ct0 component addition
    verify_add_component(c1_t0, c2_t0, csum_t0, qi, r1_t0);

    // Verify ct1 component addition
    verify_add_component(c1_t1, c2_t1, csum_t1, qi, r1_t1);
}

/// Verifies the correct addition of ciphertexts across multiple CRT bases (RNS representation).
///
/// This function applies the ciphertext verification to all CRT moduli in the RNS basis.
///
/// # Arguments
/// * `c1_t0`, `c1_t1` - First ciphertext components for all CRT bases
/// * `c2_t0`, `c2_t1` - Second ciphertext components for all CRT bases
/// * `csum_t0`, `csum_t1` - Sum ciphertext components for all CRT bases
/// * `qis` - Array of CRT moduli
/// * `r1_t0`, `r1_t1` - Carry terms for each component and CRT basis
///
/// # Generic Parameters
/// * `L` - Number of CRT bases
pub fn verify_add_ciphertext_rns<let L: u32>(
    c1_t0: [Field; L],
    c1_t1: [Field; L],
    c2_t0: [Field; L],
    c2_t1: [Field; L],
    csum_t0: [Field; L],
    csum_t1: [Field; L],
    qis: [Field; L],
    r1_t0: [Field; L],
    r1_t1: [Field; L],
) {
    for i in 0..L {
        verify_add_ciphertext(
            c1_t0[i],
            c1_t1[i],
            c2_t0[i],
            c2_t1[i],
            csum_t0[i],
            csum_t1[i],
            qis[i],
            r1_t0[i],
            r1_t1[i],
        );
    }
}

/// Verifies the correct addition of polynomial ciphertexts.
///
/// This function verifies polynomial addition coefficient-wise using the Greco relations.
/// Each coefficient of the polynomial ciphertext is verified independently.
///
/// # Arguments
/// * `c1_t0`, `c1_t1` - First polynomial ciphertext components
/// * `c2_t0`, `c2_t1` - Second polynomial ciphertext components
/// * `csum_t0`, `csum_t1` - Sum polynomial ciphertext components
/// * `qi` - CRT modulus
/// * `r1_t0`, `r1_t1` - Carry polynomials for each component
///
/// # Generic Parameters
/// * `N` - Polynomial degree (ring dimension)
pub fn verify_add_polynomial_ciphertext<let N: u32>(
    c1_t0: Polynomial<N>,
    c1_t1: Polynomial<N>,
    c2_t0: Polynomial<N>,
    c2_t1: Polynomial<N>,
    csum_t0: Polynomial<N>,
    csum_t1: Polynomial<N>,
    qi: Field,
    r1_t0: Polynomial<N>,
    r1_t1: Polynomial<N>,
) {
    // Verify each coefficient independently
    for i in 0..N {
        verify_add_ciphertext(
            c1_t0.coefficients[i],
            c1_t1.coefficients[i],
            c2_t0.coefficients[i],
            c2_t1.coefficients[i],
            csum_t0.coefficients[i],
            csum_t1.coefficients[i],
            qi,
            r1_t0.coefficients[i],
            r1_t1.coefficients[i],
        );
    }
}

/// Verifies the correct addition of polynomial ciphertexts across multiple CRT bases.
///
/// This is the most general function that combines polynomial and RNS verification.
/// It verifies that polynomial ciphertext addition is correct for all coefficients
/// and all CRT moduli.
///
/// # Arguments
/// * `c1_t0`, `c1_t1` - First polynomial ciphertext components for all CRT bases
/// * `c2_t0`, `c2_t1` - Second polynomial ciphertext components for all CRT bases
/// * `csum_t0`, `csum_t1` - Sum polynomial ciphertext components for all CRT bases
/// * `qis` - Array of CRT moduli
/// * `r1_t0`, `r1_t1` - Carry polynomial arrays for each component and CRT basis
///
/// # Generic Parameters
/// * `N` - Polynomial degree (ring dimension)
/// * `L` - Number of CRT bases
pub fn verify_add_polynomial_ciphertext_rns<let N: u32, let L: u32>(
    c1_t0: [Polynomial<N>; L],
    c1_t1: [Polynomial<N>; L],
    c2_t0: [Polynomial<N>; L],
    c2_t1: [Polynomial<N>; L],
    csum_t0: [Polynomial<N>; L],
    csum_t1: [Polynomial<N>; L],
    qis: [Field; L],
    r1_t0: [Polynomial<N>; L],
    r1_t1: [Polynomial<N>; L],
) {
    for i in 0..L {
        verify_add_polynomial_ciphertext(
            c1_t0[i],
            c1_t1[i],
            c2_t0[i],
            c2_t1[i],
            csum_t0[i],
            csum_t1[i],
            qis[i],
            r1_t0[i],
            r1_t1[i],
        );
    }
}

// Extended functionality for n > 2 addends
// Note: For n > 2, the bound changes to |r1| <= floor((n-1)/2)

/// Verifies the correct addition with a custom bound on the carry term.
///
/// This function allows for verification of addition with more than 2 addends
/// by accepting a custom bound for the carry term r1.
///
/// # Arguments
/// * `c1` - First ciphertext component
/// * `c2` - Second ciphertext component
/// * `c_sum` - Reduced sum component
/// * `qi` - CRT modulus
/// * `r1` - Carry/recentering term
/// * `bound` - Maximum allowed absolute value for r1
pub fn verify_add_component_with_bound(
    c1: Field,
    c2: Field,
    c_sum: Field,
    qi: Field,
    r1: Field,
    bound: u32,
) {
    // Compute pre-reduction sum
    let pre_sum = c1 + c2;

    // Enforce Greco relation: pre_sum = c_sum + r1 * qi
    assert_eq(pre_sum, c_sum + r1 * qi);

    // For larger bounds, we need a range check
    // This is a simplified version - in practice, you might want to use
    // bit decomposition or other range checking techniques
    if bound == 1 {
        // Special case: r1 in {-1, 0, 1}
        assert_eq(r1 * (r1 - 1) * (r1 + 1), 0);
    } else {
        // For larger bounds, implement proper range checking
        // This is a placeholder - implement according to your range checking strategy
        assert(r1 as u32 <= bound);
        assert((-r1) as u32 <= bound);
    }
}
