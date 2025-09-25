# Greco Addition

A Noir circuit project demonstrating the use of the Greco crate for BFV (Brakerski-Fan-Vercauteren) public key encryption verification.

## Overview

This project demonstrates how to set up and use the Greco crate in a Noir project. The Greco crate provides zero-knowledge proof functionality for verifying correct BFV ciphertext formation without revealing secrets.

## Features

- **BFV Encryption Verification**: Proves that ciphertext components are correctly computed from public key components and encryption randomness
- **Range Checking**: Validates that all polynomial coefficients are within expected bounds  
- **Fiat-Shamir Transform**: Uses cryptographic sponge for non-interactive proof generation
- **Polynomial Identity Testing**: Leverages Schwartz-Zippel lemma for efficient verification

## Dependencies

This project uses the following dependencies:

- **Greco**: Main BFV encryption verification circuit (included as local module in `src/greco.nr`)
- **Polynomial**: Polynomial operations and utilities (included as local module in `src/polynomial.nr`)
- **Safe**: Cryptographic sponge implementation (included as local module in `src/safe.nr`)
- **Poseidon**: Hash function implementation (Git dependency from noir-lang/poseidon)
- **SHA256**: Hash function for cryptographic operations (Git dependency from noir-lang/sha256)

## Circuit Structure

The main circuit (`src/main.nr`) implements:

1. **Parameter Setup**: Cryptographic and bound parameters for the BFV scheme
2. **Polynomial Inputs**: Public key, ciphertext, and witness polynomials
3. **Greco Circuit Creation**: Instantiates the verification circuit with all parameters
4. **Binary Constraint**: Ensures proper message encoding (k1 coefficient constraint)
5. **Ciphertext Verification**: Calls the main verification function

## Generic Parameters

- `N = 2048`: Polynomial degree (ring dimension)
- `L = 1`: Number of CRT (Chinese Remainder Theorem) bases

## Circuit Inputs

### Public Inputs
- `params`: Cryptographic and bound parameters
- `pk0is`, `pk1is`: Public key polynomials for each CRT basis
- `ct0is`, `ct1is`: Ciphertext polynomials for each CRT basis

### Private Inputs (Witnesses)
- `u`: Secret polynomial from ternary distribution
- `e0`, `e1`: Error polynomials from discrete Gaussian distribution
- `k1`: Scaled message polynomial
- `r1is`, `r2is`: Randomness polynomials for ct0 computation
- `p1is`, `p2is`: Randomness polynomials for ct1 computation

## Verification Equations

The circuit proves the following encryption equations for each CRT basis i:

```
ct0i(γ) = pk0i(γ) * u(γ) + e0(γ) + k1(γ) * k0i + r1i(γ) * qi + r2i(γ) * cyclo(γ)
ct1i(γ) = pk1i(γ) * u(γ) + e1(γ) + p1i(γ) * qi + p2i(γ) * cyclo(γ)
```

Where `cyclo(γ) = γ^N + 1` is the cyclotomic polynomial.

## Usage

### Compilation

```bash
nargo check
```

### Building Circuit

```bash
nargo compile
```

### Testing

To test with actual parameters, you would need to:

1. Generate valid BFV encryption parameters and polynomials
2. Create a `Prover.toml` file with the actual values
3. Run `nargo prove` to generate a proof

## Development

The current implementation provides a framework for BFV encryption verification. To use it with real data:

1. Use the Enclave SDK or BFV library to generate proper encryption parameters
2. Perform BFV encryption to get the required polynomial values  
3. Create witness data for all the randomness polynomials used in encryption
4. Format the data according to the circuit's expected input structure

## Compatibility

- Noir version: 1.0.0-beta.12
- Compatible with the Enclave project's Greco implementation

## References

- [Greco Paper](https://eprint.iacr.org/2024/594) - Research paper on zero-knowledge proofs for BFV encryption correctness
- [Enclave Project](https://github.com/gnosisguild/enclave) - Source of the Greco crate implementation
- [Original Halo2 Implementation](https://github.com/privacy-scaling-explorations/greco) - Reference implementation by PSE

## License

This project follows the same license as the Greco crate (LGPL-3.0-only).