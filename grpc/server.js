const PROTO_PATH = __dirname + '/delta-zk.proto';
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const { prove } = require('./service.js')
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

function main() {
    let server = new grpc.Server();
    server.addService(delta_proto.ZKP.service,
        {
            prove: prove
        }
    );

    server.bindAsync('0.0.0.0:4500', grpc.ServerCredentials.createInsecure(), ()=> {
        console.log('RPC服务已运行在4500端口')
        server.start();
    });
}

main();
