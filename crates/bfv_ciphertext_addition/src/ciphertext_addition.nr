// SPDX-License-Identifier: LGPL-3.0-only
//
// This file contains homomorphic addition operations for BFV ciphertexts
//
// This module provides functions for adding two BFV ciphertexts together
// using the additive homomorphism property of the BFV scheme.

use polynomial::Polynomial;

/// Performs homomorphic addition of two ciphertext pairs
/// Inputs: (ct0is, ct1is) and (ct0js, ct1js)
/// Output: (sum_ct0is, sum_ct1is)
pub fn add_ciphertexts(
    ct0is: [Polynomial<2048>; 1],
    ct1is: [Polynomial<2048>; 1],
    ct0js: [Polynomial<2048>; 1],
    ct1js: [Polynomial<2048>; 1],
) -> ([Polynomial<2048>; 1], [Polynomial<2048>; 1]) {
    let mut sum_ct0is: [Polynomial<2048>; 1] = ct0is;
    let mut sum_ct1is: [Polynomial<2048>; 1] = ct1is;

    // Single-limb (RNS=1) case; if you extend to multiple limbs, loop over limbs
    for i in 0..2048 {
        // Coefficient-wise addition (mod q to be enforced if you wire q below)
        let s0 = ct0is[0].coefficients[i] + ct0js[0].coefficients[i];
        let s1 = ct1is[0].coefficients[i] + ct1js[0].coefficients[i];

        // TODO (optional): reduce modulo qi for limb 0.
        // Example pattern once you expose q via params:
        //   let q0 = params.crypto_params().q_at(0); // <- replace with actual accessor
        //   let b0 = witness Field; constrain b0 * (b0 - 1) == 0; // carry bit
        //   let out0 = s0 - b0 * q0; safe::assert_lt(out0, q0); // 0 <= out0 < q
        //   sum_ct0is[0].coefficients[i] = out0;
        // Same for s1 -> out1

        // For now, store raw sums (consumer may add mod-q reduction if desired)
        sum_ct0is[0].coefficients[i] = s0;
        sum_ct1is[0].coefficients[i] = s1;
    }

    // Return public outputs (ciphertext of the sum)
    (sum_ct0is, sum_ct1is)
}

// ############################################################################
// TESTS
// ############################################################################

// Helper function to create a polynomial with specific coefficients
fn create_polynomial(coefficients: [Field; 2048]) -> Polynomial<2048> {
    let mut poly: Polynomial<2048> = Polynomial { coefficients: [0; 2048] };
    for i in 0..2048 {
        poly.coefficients[i] = coefficients[i];
    }
    poly
}

// Helper function to create a zero polynomial
fn create_zero_polynomial() -> Polynomial<2048> {
    create_polynomial([0; 2048])
}

// Helper function to create a polynomial with all coefficients set to a value
fn create_constant_polynomial(value: Field) -> Polynomial<2048> {
    create_polynomial([value; 2048])
}

// Helper function to create a polynomial with coefficients [0, 1, 2, ..., 2047]
fn create_identity_polynomial() -> Polynomial<2048> {
    let mut coefficients = [0; 2048];
    for i in 0..2048 {
        coefficients[i] = i as Field;
    }
    create_polynomial(coefficients)
}

// Helper function to check if two polynomials are equal
fn assert_polynomials_equal(a: Polynomial<2048>, b: Polynomial<2048>) {
    for i in 0..2048 {
        assert(a.coefficients[i] == b.coefficients[i]);
    }
}

// Test 1: Basic addition of zero polynomials
#[test]
fn test_add_zero_polynomials() {
    let zero_poly = create_zero_polynomial();
    let ct0is = [zero_poly];
    let ct1is = [zero_poly];
    let ct0js = [zero_poly];
    let ct1js = [zero_poly];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Result should be zero polynomials
    assert_polynomials_equal(result_ct0[0], create_zero_polynomial());
    assert_polynomials_equal(result_ct1[0], create_zero_polynomial());
}

// Test 2: Addition of constant polynomials
#[test]
fn test_add_constant_polynomials() {
    let const_1 = create_constant_polynomial(1);
    let const_2 = create_constant_polynomial(2);
    let const_3 = create_constant_polynomial(3);
    let const_4 = create_constant_polynomial(4);

    let ct0is = [const_1];
    let ct1is = [const_2];
    let ct0js = [const_3];
    let ct1js = [const_4];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Result should be constant polynomials with values 1+3=4 and 2+4=6
    assert_polynomials_equal(result_ct0[0], create_constant_polynomial(4));
    assert_polynomials_equal(result_ct1[0], create_constant_polynomial(6));
}

// Test 3: Addition of identity polynomials
#[test]
fn test_add_identity_polynomials() {
    let identity = create_identity_polynomial();
    let ct0is = [identity];
    let ct1is = [identity];
    let ct0js = [identity];
    let ct1js = [identity];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Each coefficient should be doubled
    for i in 0..2048 {
        assert(result_ct0[0].coefficients[i] == (i as Field) * 2);
        assert(result_ct1[0].coefficients[i] == (i as Field) * 2);
    }
}

// Test 4: Addition with mixed polynomial types
#[test]
fn test_add_mixed_polynomials() {
    let zero = create_zero_polynomial();
    let identity = create_identity_polynomial();
    let const_5 = create_constant_polynomial(5);

    let ct0is = [zero];
    let ct1is = [identity];
    let ct0js = [const_5];
    let ct1js = [zero];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // ct0: 0 + 5 = 5, ct1: identity + 0 = identity
    assert_polynomials_equal(result_ct0[0], create_constant_polynomial(5));
    assert_polynomials_equal(result_ct1[0], identity);
}

// Test 5: Test specific coefficient positions
#[test]
fn test_specific_coefficients() {
    let mut poly1 = create_zero_polynomial();
    let mut poly2 = create_zero_polynomial();
    let mut poly3 = create_zero_polynomial();
    let mut poly4 = create_zero_polynomial();

    // Set specific coefficients
    poly1.coefficients[0] = 10;
    poly1.coefficients[100] = 20;
    poly1.coefficients[2047] = 30;

    poly2.coefficients[0] = 5;
    poly2.coefficients[100] = 15;
    poly2.coefficients[2047] = 25;

    poly3.coefficients[0] = 3;
    poly3.coefficients[100] = 7;
    poly3.coefficients[2047] = 11;

    poly4.coefficients[0] = 2;
    poly4.coefficients[100] = 8;
    poly4.coefficients[2047] = 13;

    let ct0is = [poly1];
    let ct1is = [poly2];
    let ct0js = [poly3];
    let ct1js = [poly4];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Check specific coefficient additions
    assert(result_ct0[0].coefficients[0] == 13); // 10 + 3
    assert(result_ct0[0].coefficients[100] == 27); // 20 + 7
    assert(result_ct0[0].coefficients[2047] == 41); // 30 + 11

    assert(result_ct1[0].coefficients[0] == 7); // 5 + 2
    assert(result_ct1[0].coefficients[100] == 23); // 15 + 8
    assert(result_ct1[0].coefficients[2047] == 38); // 25 + 13
}

// Test 6: Test with large field values
#[test]
fn test_large_field_values() {
    let large_value1 = 0x7FFFFFFFFFFFFFFF; // Large field value
    let large_value2 = 0x3FFFFFFFFFFFFFFF; // Another large field value

    let poly1 = create_constant_polynomial(large_value1);
    let poly2 = create_constant_polynomial(large_value2);
    let poly3 = create_constant_polynomial(1);
    let poly4 = create_constant_polynomial(2);

    let ct0is = [poly1];
    let ct1is = [poly2];
    let ct0js = [poly3];
    let ct1js = [poly4];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Check that addition is performed correctly
    assert(result_ct0[0].coefficients[0] == large_value1 + 1);
    assert(result_ct1[0].coefficients[0] == large_value2 + 2);

    // Verify all coefficients are the same
    for i in 1..2048 {
        assert(result_ct0[0].coefficients[i] == result_ct0[0].coefficients[0]);
        assert(result_ct1[0].coefficients[i] == result_ct1[0].coefficients[0]);
    }
}

// Test 7: Test commutativity (a + b = b + a)
#[test]
fn test_commutativity() {
    let poly1 = create_identity_polynomial();
    let poly2 = create_constant_polynomial(42);
    let poly3 = create_constant_polynomial(17);
    let poly4 = create_constant_polynomial(99);

    let ct0is = [poly1];
    let ct1is = [poly2];
    let ct0js = [poly3];
    let ct1js = [poly4];

    // First addition: (poly1, poly2) + (poly3, poly4)
    let (result1_ct0, result1_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Second addition: (poly3, poly4) + (poly1, poly2)
    let (result2_ct0, result2_ct1) = add_ciphertexts(ct0js, ct1js, ct0is, ct1is);

    // Results should be identical
    assert_polynomials_equal(result1_ct0[0], result2_ct0[0]);
    assert_polynomials_equal(result1_ct1[0], result2_ct1[0]);
}

// Test 8: Test associativity ((a + b) + c = a + (b + c))
#[test]
fn test_associativity() {
    let poly1 = create_constant_polynomial(1);
    let poly2 = create_constant_polynomial(2);
    let poly3 = create_constant_polynomial(3);
    let poly4 = create_constant_polynomial(4);
    let poly5 = create_constant_polynomial(5);
    let poly6 = create_constant_polynomial(6);

    // First: (poly1, poly2) + (poly3, poly4)
    let (temp_ct0, temp_ct1) = add_ciphertexts([poly1], [poly2], [poly3], [poly4]);

    // Then: result + (poly5, poly6)
    let (result1_ct0, result1_ct1) = add_ciphertexts(temp_ct0, temp_ct1, [poly5], [poly6]);

    // Alternative: (poly3, poly4) + (poly5, poly6)
    let (temp2_ct0, temp2_ct1) = add_ciphertexts([poly3], [poly4], [poly5], [poly6]);

    // Then: (poly1, poly2) + result
    let (result2_ct0, result2_ct1) = add_ciphertexts([poly1], [poly2], temp2_ct0, temp2_ct1);

    // Results should be identical
    assert_polynomials_equal(result1_ct0[0], result2_ct0[0]);
    assert_polynomials_equal(result1_ct1[0], result2_ct1[0]);
}

// Test 9: Test that the function preserves polynomial structure
#[test]
fn test_polynomial_structure_preservation() {
    let mut poly1 = create_zero_polynomial();
    let mut poly2 = create_zero_polynomial();
    let mut poly3 = create_zero_polynomial();
    let mut poly4 = create_zero_polynomial();

    // Set some coefficients to non-zero values
    for i in 0..2048 {
        if i % 100 == 0 {
            poly1.coefficients[i] = i as Field;
            poly2.coefficients[i] = (i * 2) as Field;
            poly3.coefficients[i] = (i * 3) as Field;
            poly4.coefficients[i] = (i * 4) as Field;
        }
    }

    let ct0is = [poly1];
    let ct1is = [poly2];
    let ct0js = [poly3];
    let ct1js = [poly4];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Verify that the structure is preserved (coefficients are added correctly)
    for i in 0..2048 {
        if i % 100 == 0 {
            assert(result_ct0[0].coefficients[i] == (i as Field) + (i * 3) as Field);
            assert(result_ct1[0].coefficients[i] == ((i * 2) as Field) + ((i * 4) as Field));
        } else {
            assert(result_ct0[0].coefficients[i] == 0);
            assert(result_ct1[0].coefficients[i] == 0);
        }
    }
}

// Test 10: Test with maximum field value
#[test]
fn test_maximum_field_value() {
    let max_field = 0xFFFFFFFFFFFFFFFF; // Maximum field value
    let poly1 = create_constant_polynomial(max_field);
    let poly2 = create_constant_polynomial(1);
    let poly3 = create_constant_polynomial(0);
    let poly4 = create_constant_polynomial(0);

    let ct0is = [poly1];
    let ct1is = [poly2];
    let ct0js = [poly3];
    let ct1js = [poly4];

    let (result_ct0, result_ct1) = add_ciphertexts(ct0is, ct1is, ct0js, ct1js);

    // Check that addition works with maximum field values
    assert(result_ct0[0].coefficients[0] == max_field);
    assert(result_ct1[0].coefficients[0] == 1);

    // Verify all coefficients are the same
    for i in 1..2048 {
        assert(result_ct0[0].coefficients[i] == result_ct0[0].coefficients[0]);
        assert(result_ct1[0].coefficients[i] == result_ct1[0].coefficients[0]);
    }
}
