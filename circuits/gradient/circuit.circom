pragma circom 2.0.6;

include "../hash/circuit.circom";
include "../sigmoid/circuit.circom";
include "../vector/circuit.circom";

// 计算梯度，输入有符号，输出无符号
template G(N, d) {
    signal input X[128][N][2];
    signal input W[N][2];
    signal input Y[128][2];
    signal output G[N][2];
    signal output hash;
    signal output root;

    component xw1 = MatrixVectorMultiSign(128, N, d, d);
    component xw2 = MatrixVectorMultiSignX(N, 128, d, d*2+5);
    component sgv = SigmoidVector(128, d+d);
    component va = VectorAdd(128, d*2+5);
    component us[128];
    component H = VectorHash(N);
    component MR = MerkleMatrix128(N);

    // XW
    for (var i = 0; i < N; i++) {
        xw1.W[i][0] <== W[i][0];
        xw1.W[i][1] <== W[i][1];
    }

    for (var i = 0; i < 128; i++) {
        for (var j = 0; j < N; j++) {
            xw1.X[i][j][0] <== X[i][j][0];
            xw1.X[i][j][1] <== X[i][j][1];
        }
    }

    // sigmoid(XW)
    for (var i = 0; i < 128; i++) {
        sgv.X[i] <== xw1.P[i][0];
    }

    // Y - sigmoid(XW)
    for (var i = 0; i < 128; i++) {
        us[i] = UnSign();
        us[i].in <== Y[i][0];
        us[i].sign <== Y[i][1];

        va.L[i] <== us[i].out;
        va.R[i] <== -sgv.S[i][0];
    }

    // X'(Y - sigmoid(XW))
    for (var i = 0; i < 128; i++) {
        xw2.W[i] <== va.S[i][0];
        d*2 + 5 === va.S[i][1];
    }

    for (var i = 0; i < N; i++) {
        for (var j = 0; j < 128; j++) {
            xw2.X[i][j][0] <== X[j][i][0];
            xw2.X[i][j][1] <== X[j][i][1];
        }
    }

    for (var i = 0; i < N; i++) {
        G[i][0] <== xw2.P[i][0];
        G[i][1] <== xw2.P[i][1];
    }    

    // hash(W)
    for (var i = 0; i < N; i++) {
        H.in[i][0] <== W[i][0];
        H.in[i][1] <== W[i][1];
    }

    hash <== H.out;

    // MerkeRoot(X)
    for (var i = 0; i < 128; i++) {
        for (var j = 0; j< N; j++) {
            MR.X[i][j][0] <== X[i][j][0];
            MR.X[i][j][1] <== X[i][j][1];
        }
    }

    root <== MR.out;
}

 component main = G(3, 8);

