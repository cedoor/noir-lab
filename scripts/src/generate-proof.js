import { UltraHonkBackend } from '@aztec/bb.js';
import { Noir } from '@noir-lang/noir_js';
import { readProverTomlAsJson } from './toml-to-json.js';
import { getCircuitJson } from './utils.js';

async function generateProof(circuitName) {
    const circuitJson = getCircuitJson(circuitName);

    const noir = new Noir(circuitJson);
    const backend = new UltraHonkBackend(circuitJson.bytecode);

    const proverInputs = readProverTomlAsJson(circuitName);

    const { witness } = await noir.execute(proverInputs);

    // Measure the time it needs to generate a proof.
    const startTime = performance.now();

    await backend.generateProof(witness);

    const endTime = performance.now();
    const generationTime = endTime - startTime;

    await backend.destroy();

    console.log(`Proof generated in ${generationTime.toFixed(2)}ms`);
}

// Run CLI if this file is executed directly.
if (import.meta.url === `file://${process.argv[1]}`) {
    const circuitName = process.argv[2];

    if (!circuitName) {
        console.error('Circuit name is required');
        process.exit(1);
    }

    generateProof(circuitName);
}