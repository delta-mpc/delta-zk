const { execSync } = require('child_process');
const fs = require('fs');
const snarkjs = require("snarkjs")

let BASE = 'circuits'
let DIR = 'main'
let WORKDIR

async function generate(N, M) {
    DIR = `${DIR}/${N}_${M}`
    WORKDIR = `${BASE}/${DIR}`

    if (fs.existsSync(WORKDIR)) {
        return
    }
    fs.mkdirSync(WORKDIR, { recursive: true });

    const circuit = `pragma circom 2.0.6;\ninclude "../../gradient/circuit.circom";\ncomponent main {public [W]}= G(${N}, ${M}, 4);`

    fs.writeFileSync(`${WORKDIR}/circuit.circom`, circuit)

    execSync(`DIR=${DIR} make compile`)

    await snarkjs.plonk.setup(`${WORKDIR}/circuit.r1cs`, 'pot_final.ptau', `${WORKDIR}/circuit_final.zkey`)

    const vk = await snarkjs.zKey.exportVerificationKey(`${WORKDIR}/circuit_final.zkey`)

    fs.writeFileSync(`${WORKDIR}/verification_key.json`, JSON.stringify(vk))

    return
}

async function prove(input) {
    const N = input.X.length
    const M = input.X[0].length

    await generate(N, M)

    const { proof, publicSignals } = await snarkjs.plonk.fullProve(input, `${WORKDIR}/circuit.wasm`, `${WORKDIR}/circuit_final.zkey`);

    return { proof, publicSignals }
}

generate(10, 5).then(() => {
    process.exit(0);
})