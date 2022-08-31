const { execSync } = require('child_process');
const fs = require('fs');
const snarkjs = require("snarkjs")
const path = require("path")

let BASE = 'circuits'
let DIR = 'main'
let WORKDIR

async function templates() {
    const snarkjsRoot = path.dirname(require.resolve("snarkjs"));
    const templateDir = fs.existsSync(path.join(snarkjsRoot, "templates")) ? "templates" : "../templates";

    const verifierGroth16TemplatePath = path.join(snarkjsRoot, templateDir, "verifier_groth16.sol.ejs");
    const verifierPlonkTemplatePath = path.join(snarkjsRoot, templateDir, "verifier_plonk.sol.ejs");

    const groth16Template = fs.readFileSync(verifierGroth16TemplatePath, "utf8");
    const plonkTemplate = fs.readFileSync(verifierPlonkTemplatePath, "utf8");

    return {
        groth16: groth16Template,
        plonk: plonkTemplate,
    }
}

async function setup(N) {
    DIR = `${DIR}/${N}`
    WORKDIR = `${BASE}/${DIR}`

    if (fs.existsSync(WORKDIR)) {
        console.log('setup has been done')
        return
    }
    fs.mkdirSync(WORKDIR, { recursive: true });

    const circuit = `pragma circom 2.0.6;\ninclude "../../gradient/circuit.circom";\ncomponent main = G128(${N}, 8);`

    fs.writeFileSync(`${WORKDIR}/circuit.circom`, circuit)

    console.log('compiling circuits...')

    execSync(`DIR=${DIR} make compile`)

    console.log('plonk setup...')

    await snarkjs.plonk.setup(`${WORKDIR}/circuit.r1cs`, 'pot_final.ptau', `${WORKDIR}/circuit_final.zkey`)

    console.log('export verification key...')

    const vk = await snarkjs.zKey.exportVerificationKey(`${WORKDIR}/circuit_final.zkey`)

    fs.writeFileSync(`${WORKDIR}/verification_key.json`, JSON.stringify(vk))

    console.log('export solidity verifier...')

    const sol = await snarkjs.zKey.exportSolidityVerifier(`${WORKDIR}/circuit_final.zkey`, await templates())

    fs.writeFileSync(`${WORKDIR}/verifier.sol`, sol)

    return
}

async function prove(input) {
    const N = input.W.length

    await setup(N)

    const { proof, publicSignals } = await snarkjs.plonk.fullProve(input, `${WORKDIR}/circuit.wasm`, `${WORKDIR}/circuit_final.zkey`);

    return { proof: JSON.stringify(proof), publicSignals }
}

function sign(x) {
    if (x >= 0) {
        return 0
    } else {
        return 1
    }
}

function padding(X, Y) {
    let M = X.length
    let N = X[0].length
    let paddingSize = 128 - M % 128
    for (let i = 0; i < paddingSize; i++) {
        X.push(Array(N).fill(0))
        Y.push(0)
    }
}

function circomInput(X, W, Y, d = 8) {
    if (X.length != Y.length) {
        console.log('inconsisitent size of input X and Y')
        process.exit(1)
    }
    if (X[0].length != W.length) {
        console.log('inconsisitent size of input X and W')
        process.exit(1)
    }

    let fac = 10 ** d
    let fac2 = 10 ** (d * 2 + 5);
    for (let i = 0; i < X.length; i++) {
        if (X[i].length != W.length) {
            console.log('inconsisitent size of input X and W')
            process.exit(1)
        }
        X[i] = X[i].map(x => [Math.floor(Math.abs(x) * fac), sign(x)]);
    }
    W = W.map(x => [Math.floor(Math.abs(x) * fac), sign(x)]);
    Y = Y.map(y => [Math.floor(Math.abs(y) * fac2), sign(y)]);

    return { X, W, Y }
}

module.exports = {
    circomInput,
    padding,
    setup,
    prove
}