import { useCallback, useEffect, useState } from 'react'
import { UltraHonkBackend, type ProofData } from '@aztec/bb.js';
import { Noir, type CompiledCircuit } from '@noir-lang/noir_js';
import circuit from '../../../target/bfv_ciphertext_addition.json';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';

function BFVCiphertextAddition() {
    const [noir, setNoir] = useState<Noir | null>(null);
    const [backend, setBackend] = useState<UltraHonkBackend | null>(null);
    const [proof, setProof] = useState<ProofData | null>(null);
    const [result, setResult] = useState<string | null>(null);
    const [isValid, setIsValid] = useState<boolean | null>(null);
    const [isGenerating, setIsGenerating] = useState<boolean>(false);
    const [isVerifying, setIsVerifying] = useState<boolean>(false);

    useEffect(() => {
        const noir = new Noir(circuit as CompiledCircuit);
        const backend = new UltraHonkBackend(circuit.bytecode);

        setNoir(noir);
        setBackend(backend);
    }, []);

    const generateProof = useCallback(async () => {
        if (!noir || !backend) return;

        setIsGenerating(true);
        try {
            const inputs = await fetch('/noir-lab/bfv_ciphertext_addition_inputs.json', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            }).then(response => response.json());

            const { witness, returnValue } = await noir.execute(inputs);
            const proof = await backend.generateProof(witness);

            setProof(proof);
            setResult(returnValue ? returnValue.toString() : 'No return value');

            setIsValid(null);
            console.log("Proof generated", proof);
        } catch (error) {
            console.error('Error generating proof:', error);
            alert('Error generating proof. This circuit requires proper parameters.');
        } finally {
            setIsGenerating(false);
        }
    }, [noir, backend]);

    const verifyProof = useCallback(async () => {
        if (!backend || !proof) return;

        setIsVerifying(true);
        try {
            const isValid = await backend.verifyProof(proof);
            setIsValid(isValid);
        } catch (error) {
            console.error('Error verifying proof:', error);
            alert('Error verifying proof.');
        } finally {
            setIsVerifying(false);
        }
    }, [backend, proof]);

    return (
        <div className="w-full max-w-2xl mx-auto space-y-6">
            <div className="text-center space-y-2">
                <h1 className="text-3xl font-bold tracking-tight">BFV Ciphertext Addition</h1>
                <p className="text-muted-foreground">
                    This circuit verifies BFV ciphertext addition using homomorphic encryption.
                </p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Circuit Parameters</CardTitle>
                    <CardDescription>
                        This circuit demonstrates BFV ciphertext addition verification.
                        Note: This requires proper parameters to work correctly,
                        which have been previously generated.
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="p-4 bg-muted rounded-lg">
                        <p className="text-sm text-muted-foreground mb-2">Circuit Info:</p>
                        <ul className="text-sm space-y-1">
                            <li>• Polynomial degree: 2048</li>
                            <li>• Plaintext modulus: 1032193</li>
                            <li>• Constraints: 134880</li>
                        </ul>
                    </div>
                    
                    <Button 
                        onClick={generateProof} 
                        disabled={isGenerating || !noir || !backend}
                        className="w-full"
                    >
                        {isGenerating ? 'Generating Proof...' : 'Generate Proof'}
                    </Button>
                </CardContent>
            </Card>

            {proof && (
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <span className="text-green-600 dark:text-green-400">✓</span>
                            Proof Generated Successfully
                        </CardTitle>
                        <CardDescription>
                            Your proof has been generated. You can now verify the proof.
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {result && (
                            <div className="p-4 bg-muted rounded-lg">
                                <p className="text-sm text-muted-foreground mb-2">Circuit Result:</p>
                                <p className="text-lg font-mono font-bold break-all">
                                    {result}
                                </p>
                            </div>
                        )}
                        
                        <Button 
                            onClick={verifyProof} 
                            disabled={isVerifying}
                            className="w-full"
                            variant="outline"
                        >
                            {isVerifying ? 'Verifying...' : 'Verify Proof'}
                        </Button>
                        
                        {isValid !== null && (
                            <div className={`p-4 rounded-lg ${
                                isValid 
                                    ? 'bg-green-50 dark:bg-green-950 border border-green-200 dark:border-green-800' 
                                    : 'bg-red-50 dark:bg-red-950 border border-red-200 dark:border-red-800'
                            }`}>
                                <p className={`text-sm font-medium ${
                                    isValid 
                                        ? 'text-green-800 dark:text-green-200' 
                                        : 'text-red-800 dark:text-red-200'
                                }`}>
                                    {isValid ? '✓ Proof is valid!' : '✗ Proof is invalid'}
                                </p>
                            </div>
                        )}
                    </CardContent>
                </Card>
            )}
        </div>
    )
}

export default BFVCiphertextAddition;
