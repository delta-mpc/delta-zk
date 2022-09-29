const PROTO_PATH = __dirname + '/delta-zk.proto';
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const { proveAll } = require('./service.js')
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
            prove: proveAll
        }
    );

    server.bindAsync('0.0.0.0:3400', grpc.ServerCredentials.createInsecure(), ()=> {
        console.log('delta-zk rpc服务已运行在 3400 端口')
        server.start();
    });
}

main();
