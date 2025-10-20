import { readFileSync } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function getPaths(circuitName) {
    const targetPath = path.join(__dirname, "../../target");
    const cratesPath = path.join(__dirname, "../../crates");

    return {
        targetPath,
        cratesPath,
        circuitPath: path.join(targetPath, `${circuitName}.json`),
        proverTomlPath: path.join(cratesPath, circuitName, 'Prover.toml')
    };
}

export function getCircuitJson(circuitName) {
    const {circuitPath} = getPaths(circuitName);
    
    const circuitJson = readFileSync(circuitPath, 'utf8');

    return JSON.parse(circuitJson);
}