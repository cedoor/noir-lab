import fs from 'fs';
import path from 'path';
import { parse } from 'toml';
import { getPaths } from './utils.js';

/**
 * Reads a Prover.toml file and returns its JSON-compatible object.
 * The returned object mirrors the TOML structure dynamically.
 */
export function readProverTomlAsJson(circuitName) {
    const { proverTomlPath } = getPaths(circuitName);

    const tomlContent = fs.readFileSync(proverTomlPath, 'utf-8');
    
    return parse(tomlContent);
}

/**
 * CLI function to convert Prover.toml files
 */
export function convertProverTomlCli(circuitName) {
    try {
        const jsonInputs = readProverTomlAsJson(circuitName);
        const outputPath = path.join(process.cwd(), `${circuitName}_inputs.json`);

        fs.writeFileSync(outputPath, JSON.stringify(jsonInputs, null, 2));

        console.log(`Converted toml file to json file at ${circuitName}.json`);
    } catch (error) {
        console.error('Conversion failed:', error);
        process.exit(1);
    }
}

// Run CLI if this file is executed directly.
if (import.meta.url === `file://${process.argv[1]}`) {
    const circuitName = process.argv[2];

    if (!circuitName) {
        console.error('Circuit name is required');
        process.exit(1);
    }

    convertProverTomlCli(circuitName);
}
