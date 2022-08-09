const snarkjs = require("snarkjs");

async function run() {
    const start = new Date().getTime()
    const input = require('./input.json')
    const {proof, publicSignals} = await snarkjs.plonk.fullProve(input, "circuit.wasm", "circuit_final.zkey");
    console.log('proof cost is', `${new Date().getTime() - start}ms`)
    console.log('publicSignals', `${JSON.stringify(publicSignals)}`)

    const vKey = require("./verification_key.json")
    const res = await snarkjs.plonk.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }
    console.log('total cost is', `${new Date().getTime() - start}ms`)
}


run().then(() => {
    process.exit(0);
});
