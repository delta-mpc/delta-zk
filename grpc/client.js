const PROTO_PATH = __dirname + '/delta-zk.proto';
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const packageDefinition = protoLoader.loadSync(
    PROTO_PATH,
    {
        keepCase: true,
        longs: String,
        enums: String,
        defaults: true,
        oneofs: true
    });
const delta_proto = grpc.loadPackageDefinition(packageDefinition).delta;
const client = new delta_proto.ZKP('127.0.0.1:4500', grpc.credentials.createInsecure())

function prove(input) {
    let call = client.prove(input, () => { })
    call.on('data', (res) => {
        console.log(res)
    })
    call.on('end', () => {
        console.log('prove end')
    })
}

let input = {
    xy: [
        { d: [2.66, 20.0, 0.0, 0] },
        { d: [2.89, 22.0, 0.0, 0] },
        { d: [3.28, 24.0, 0.0, 0] },
        { d: [2.92, 12.0, 0.0, 0] },
        { d: [4.0, 21.0, 0.0, 1] },
        { d: [2.86, 17.0, 0.0, 0] },
        { d: [2.76, 17.0, 0.0, 0] },
        { d: [2.87, 21.0, 0.0, 0] },
        { d: [3.03, 25.0, 0.0, 0] },
        { d: [3.92, 29.0, 0.0, 1] },
        { d: [2.63, 20.0, 0.0, 0] },
        { d: [3.32, 23.0, 0.0, 0] },
        { d: [3.57, 23.0, 0.0, 0] },
        { d: [3.26, 25.0, 0.0, 1] },
        { d: [3.53, 26.0, 0.0, 0] },
        { d: [2.74, 19.0, 0.0, 0] },
        { d: [2.75, 25.0, 0.0, 0] },
        { d: [2.83, 19.0, 0.0, 0] },
        { d: [3.12, 23.0, 1.0, 0] },
        { d: [3.16, 25.0, 1.0, 1] },
        { d: [2.06, 22.0, 1.0, 0] },
        { d: [3.62, 28.0, 1.0, 1] },
        { d: [2.89, 14.0, 1.0, 0] },
        { d: [3.51, 26.0, 1.0, 0] },
        { d: [3.54, 24.0, 1.0, 1] },
        { d: [2.83, 27.0, 1.0, 1] },
        { d: [3.39, 17.0, 1.0, 1] },
        { d: [2.67, 24.0, 1.0, 0] },
        { d: [3.65, 21.0, 1.0, 1] },
        { d: [4.0, 23.0, 1.0, 1] },
        { d: [3.1, 21.0, 1.0, 0] },
        { d: [2.39, 19.0, 1.0, 1] }
    ],
    weights: [0.29933592, -0.10147248, 1.63635739]
}

prove(input)