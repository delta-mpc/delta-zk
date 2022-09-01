const { prove, circomInput, padding } = require('../snark/prove')

function proveAll(call) {
    try {
        let start = new Date()

        const input = call.request
        const X = []
        const Y = []
        const W = input.weights
    
        for (let s of input.xy) {
            let d = s.d
            X.push(d.slice(0, -1))
            Y.push(d[d.length - 1])
        }
    
        console.log(`[${start.toLocaleString()}] input size ${X.length} * ${X[0].length}`)
        padding(X, Y)
    
        const step = 128
        const epoch = X.length / step
        for (let i = 0; i < epoch; i++) {
            let x = X.slice(i * step, i * step + step)
            let y = Y.slice(i * step, i * step + step)
            let ci = circomInput(x, W, y)
            prove(ci).then(res => {
                res.index = i
                call.write(res)
                console.log(`---${(new Date().getTime() - start.getTime()) / 1000}s`)
            }).catch(err => {
                console.log(err.toString())
                call.write({ error: err.toString(), index: i })
            }).finally(() => {
                if (i === epoch - 1) {
                    call.end()
                }
            })
        }
    } catch (err) {
        console.log(err.toString())
        call.write({ error: err.toString(), index: -1 })
        call.end()
    }

}

module.exports = {
    proveAll
}