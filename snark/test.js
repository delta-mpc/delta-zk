const snarkjs = require("snarkjs")
const input = require('./input.json')
const vKey = require("./verification_key.json")

async function test() {
    const start = new Date().getTime()
    
    const {proof, publicSignals} = await snarkjs.plonk.fullProve(input, "circuit.wasm", "circuit_final.zkey");
    console.log('proof cost is ', `${new Date().getTime() - start} ms`)
    console.log('public signals ', `${JSON.stringify(publicSignals)}`)
    console.log('proof ', `${JSON.stringify(proof)}`)

    const callData = await snarkjs.plonk.exportSolidityCallData(proof, publicSignals)
    console.log('call data ', callData)
    
    const res = await snarkjs.plonk.verify(vKey, publicSignals, proof);
    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }
    console.log('total cost is ', `${new Date().getTime() - start} ms`)
}


test().then(() => {
    process.exit(0);
});
