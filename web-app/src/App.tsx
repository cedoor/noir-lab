import { useCallback, useEffect, useState } from 'react'
import './App.css'
import { UltraHonkBackend, type ProofData } from '@aztec/bb.js';
import { Noir, type CompiledCircuit } from '@noir-lang/noir_js';
import circuit from '../../target/noir_lab.json';

function App() {
  const [noir, setNoir] = useState<Noir | null>(null);
  const [backend, setBackend] = useState<UltraHonkBackend | null>(null);
  const [proof, setProof] = useState<ProofData | null>(null);

  useEffect(() => {
    const noir = new Noir(circuit as CompiledCircuit);
    const backend = new UltraHonkBackend(circuit.bytecode);

    setNoir(noir);
    setBackend(backend);
  }, []);


const generateProof = useCallback(() => {
  return async () => {
    if (!noir || !backend) return;

    const { witness } = await noir.execute({});
    const proof = await backend.generateProof(witness);

    setProof(proof);

    console.log(proof.proof);
  }
}, [noir, backend]);

const verifyProof = useCallback(() => {
  return async () => {
    if (!backend || !proof) return;

    const isValid = await backend.verifyProof(proof);

    console.log(isValid);
  }
}, [backend, proof]);

  return (
    <>
      <h1>Noir Lab</h1>
      <div className="card">
        <button onClick={generateProof()}>
          Generate Proof
        </button>
        <br />
        <br />
        <button onClick={verifyProof()}>
          Verify Proof
        </button>
      </div>
    </>
  )
}

export default App
