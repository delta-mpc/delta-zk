const { setup } = require('./prove.js');

let N = process.argv[2]
if (!N) {
    console.log('please set the input dimension, e.g. yarn setup 10')
    process.exit(0)
}

setup(N).then(() => {
    process.exit(0)
})