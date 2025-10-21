import { useCallback, useEffect, useState } from 'react'
import { UltraHonkBackend, type ProofData } from '@aztec/bb.js';
import { Noir, type CompiledCircuit } from '@noir-lang/noir_js';
import circuit from '../../../target/crisp.json';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { ZKInputsGenerator } from "crisp-zk"

function CRISP() {
    const [noir, setNoir] = useState<Noir | null>(null);
    const [backend, setBackend] = useState<UltraHonkBackend | null>(null);
    const [proof, setProof] = useState<ProofData | null>(null);
    const [result, setResult] = useState<string | null>(null);
    const [isValid, setIsValid] = useState<boolean | null>(null);
    const [isGenerating, setIsGenerating] = useState<boolean>(false);
    const [isVerifying, setIsVerifying] = useState<boolean>(false);
    const [vote, setVote] = useState<string>('1');
    const [provingTime, setProvingTime] = useState<number | null>(null);
    const [inputGenerationTime, setInputGenerationTime] = useState<number | null>(null);

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
            // Input generation timing
            const inputStartTime = performance.now();
            const generator = new ZKInputsGenerator();
            const publicKey = await generator.generatePublicKey();
            const voteValue = parseInt(vote);
            const inputs = await generator.generateInputs(publicKey, voteValue);
            const inputEndTime = performance.now();
            const inputTime = inputEndTime - inputStartTime;

            // Proving timing
            const provingStartTime = performance.now();
            const { witness, returnValue } = await noir.execute(inputs);
            const proof = await backend.generateProof(witness);
            const provingEndTime = performance.now();
            const provingTime = provingEndTime - provingStartTime;

            setProof(proof);
            setResult(returnValue ? returnValue.toString() : 'No return value');
            setInputGenerationTime(inputTime);
            setProvingTime(provingTime);

            setIsValid(null);
            console.log("Proof generated", proof);

            await backend.destroy();
        } catch (error) {
            console.error('Error generating proof:', error);
            alert('Error generating proof. This circuit requires proper parameters.');
        } finally {
            setIsGenerating(false);
        }
    }, [noir, backend, vote]);

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
                <h1 className="text-3xl font-bold tracking-tight">CRISP</h1>
                <p className="text-muted-foreground">
                    This app demonstrates all steps to generate CRISP proofs: input pre-computation, proof generation and verification.
                </p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Input Values</CardTitle>
                    <CardDescription>Enter a vote (0 or 1) to pre-compute the inputs and generate a proof.</CardDescription>
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
                    
                    <div className="space-y-2">
                        <Label htmlFor="vote">Vote (0 or 1)</Label>
                        <Input
                            id="vote"
                            type="number"
                            min="0"
                            max="1"
                            value={vote}
                            onChange={(e) => {
                                const value = e.target.value;
                                if (value === '' || value === '0' || value === '1') {
                                    setVote(value);
                                }
                            }}
                            placeholder="Enter 0 or 1"
                            className="w-full"
                        />
                    </div>
                    
                    <Button 
                        onClick={generateProof} 
                        disabled={isGenerating || !noir || !backend || (vote !== '0' && vote !== '1')}
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
                        
                        {provingTime !== null && inputGenerationTime !== null && (
                            <div className="space-y-3">
                                <div className="p-4 bg-muted rounded-lg">
                                    <p className="text-sm text-muted-foreground mb-2">Input Generation Time:</p>
                                    <p className="text-lg font-mono font-bold">
                                        {inputGenerationTime.toFixed(2)} ms
                                    </p>
                                </div>
                                <div className="p-4 bg-muted rounded-lg">
                                    <p className="text-sm text-muted-foreground mb-2">Proving Time:</p>
                                    <p className="text-lg font-mono font-bold">
                                        {provingTime.toFixed(2)} ms
                                    </p>
                                </div>
                                <div className="p-4 bg-blue-50 dark:bg-blue-950 border border-blue-200 dark:border-blue-800 rounded-lg">
                                    <p className="text-sm text-blue-800 dark:text-blue-200 mb-2">Total Time:</p>
                                    <p className="text-lg font-mono font-bold text-blue-800 dark:text-blue-200">
                                        {(inputGenerationTime + provingTime).toFixed(2)} ms
                                    </p>
                                </div>
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

export default CRISP;
