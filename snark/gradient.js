const assert = require('assert');
const { prove, circomInput, padding } = require('./prove.js');

function sigmoid(x) {
    if (x > 0) {
        return s(x)
    } else {
        return 1 - s(x)
    }
}

function s(x) {
    x = Math.abs(x);
    if (x >= 5) {
        return 1
    }
    if (x >= 2.375) {
        return 0.03125 * x + 0.84325
    }
    if (x >= 1) {
        return 0.125 * x + 0.625
    }
    return 0.25 * x + 0.5

}

function innerProduct(l, r) {
    assert(l.length == r.length, "innerProduct: vector length not equal");
    let sum = 0;
    for (let i = 0; i < l.length; i++) {
        sum += l[i] * r[i];
    }
    return sum;
}

function MatrixVectorMulti(X, W) {
    assert(X[0].length === W.length, `MatrixVectorMulti: ${X[0].length} != ${W.length}`);
    let result = [];
    for (let i = 0; i < X.length; i++) {
        result.push(innerProduct(X[i], W));
    }
    return result;
}

function MatrixTranspose(X) {
    let result = [];
    for (let i = 0; i < X[0].length; i++) {
        result.push([]);
    }
    for (let i = 0; i < X.length; i++) {
        for (let j = 0; j < X[0].length; j++) {
            result[j].push(X[i][j]);
        }
    }
    return result;
}

function VectorSub(l, r) {
    assert(l.length == r.length, "VectorSub: vector length not equal");
    let result = [];
    for (let i = 0; i < l.length; i++) {
        result.push(l[i] - r[i]);
    }
    return result;
}

function gradient(X, W, Y) {
    const xw = MatrixVectorMulti(X, W);
    const sigmoidxw = xw.map(sigmoid);
    const y = VectorSub(Y, sigmoidxw);
    const Xt = MatrixTranspose(X)
    const res = MatrixVectorMulti(Xt, y);
    return res
}

X = [
    [2.66, 20.0, 0.0],
    [2.89, 22.0, 0.0],
    [3.28, 24.0, 0.0],
    [2.92, 12.0, 0.0],
    [4.0, 21.0, 0.0],
    [2.86, 17.0, 0.0],
    [2.76, 17.0, 0.0],
    [2.87, 21.0, 0.0],
    [3.03, 25.0, 0.0],
    [3.92, 29.0, 0.0],
    [2.63, 20.0, 0.0],
    [3.32, 23.0, 0.0],
    [3.57, 23.0, 0.0],
    [3.26, 25.0, 0.0],
    [3.53, 26.0, 0.0],
    [2.74, 19.0, 0.0],
    [2.75, 25.0, 0.0],
    [2.83, 19.0, 0.0],
    [3.12, 23.0, 1.0],
    [3.16, 25.0, 1.0],
    [2.06, 22.0, 1.0],
    [3.62, 28.0, 1.0],
    [2.89, 14.0, 1.0],
    [3.51, 26.0, 1.0],
    [3.54, 24.0, 1.0],
    [2.83, 27.0, 1.0],
    [3.39, 17.0, 1.0],
    [2.67, 24.0, 1.0],
    [3.65, 21.0, 1.0],
    [4.0, 23.0, 1.0],
    [3.1, 21.0, 1.0],
    [2.39, 19.0, 1.0]
]

Y = [0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1]

W = [0.29933592, -0.10147248, 1.63635739]
// W = [0.2993, -0.1014, 1.6363]

padding(X, Y)

console.log('true gradient: ', gradient(X, W, Y))

let input = circomInput(X, W, Y)
prove(input).then((proof) => {
    console.log('proof: ', proof.publicSignals)
    process.exit(0)
})

