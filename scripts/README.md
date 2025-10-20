# Noir Lab Scripts

Utility scripts for working with Noir circuits.

## Setup

```bash
pnpm install
```

## Usage

### Generate Proof

Generate a proof for a Noir circuit:

```bash
pnpm run generate-proof <circuit-name>
```

Example:

```bash
pnpm run generate-proof bfv_ciphertext_addition
```

### Convert TOML to JSON

Convert Prover.toml files to JSON format:

```bash
pnpm run toml-to-json <circuit-name>
```

Example:

```bash
pnpm run toml-to-json bfv_ciphertext_addition
```

## Available Circuits

- `bfv_ciphertext_addition`
- `demo`
- `noir_generics`
