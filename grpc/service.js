const { prove, circomInput } = require('../snark/prove')

function proveAll(call, input) {
    let start = new Date()
    const X = []
    const Y = []
    const W = input.weights
    for (let s in input.xy) {
        X.push(s.slice(0, -1))
        Y.push(s[s.length - 1])
    }

    const msg = `[${start.toLocaleString()}] input size ${X.length} * ${X[0].length}`

    prove(circomInput(X, W, Y, 8), 8).then(res => {
        call.write(res)
        call.end()
        msg += `---${new Date().getTime() - start.getTime()}ms`
        console.log(msg)
    }).catch(err => {
        call.write({ error: err.toString() })
        call.end()
    })
}