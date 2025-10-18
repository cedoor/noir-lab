import { useCallback, useEffect, useState } from 'react'
import './App.css'
import { UltraHonkBackend, type ProofData } from '@aztec/bb.js';
import { Noir, type CompiledCircuit } from '@noir-lang/noir_js';
import circuit from '../../target/noir_generics.json';

function App() {
  const [noir, setNoir] = useState<Noir | null>(null);
  const [backend, setBackend] = useState<UltraHonkBackend | null>(null);
  const [proof, setProof] = useState<ProofData | null>(null);
  const [isValid, setIsValid] = useState<boolean | null>(null);

  useEffect(() => {
    const noir = new Noir(circuit as CompiledCircuit);
    const backend = new UltraHonkBackend(circuit.bytecode);

    setNoir(noir);
    setBackend(backend);
  }, []);


const generateProof = useCallback(() => {
  return async () => {
    if (!noir || !backend) return;

    const { witness } = await noir.execute({ a: 2, b: 2 });
    const proof = await backend.generateProof(witness);

    setProof(proof);

    console.log(proof);
  }
}, [noir, backend]);

const verifyProof = useCallback(() => {
  return async () => {
    if (!backend || !proof) return;

    const isValid = await backend.verifyProof(proof);

    setIsValid(isValid);
  }
}, [backend, proof]);

  return (
    <>
      <h1>Noir Lab</h1>
      <div className="card">
        <button onClick={generateProof()}>
          Generate Proof
        </button>
        {proof && (
          <p>Proof: ✅</p>
        )}
        <br />
        <br />
        <button onClick={verifyProof()}>
          Verify Proof
        </button>
        <br />
        {isValid !== null && (
          <p>Is valid: {isValid ? '✅' : '❌'}</p>
        )}
      </div>
    </>
  )
}

export default App
