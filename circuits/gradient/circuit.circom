pragma circom 2.0.6;

include "../hash/circuit.circom";
include "../sigmoid/circuit.circom";
include "../vector/circuit.circom";

// 计算梯度，输入有符号，输出无符号
template Gradient(M, N, d) {
    signal input X[M][N][2];
    signal input W[N][2];
    signal input Y[M][2];
    signal output G[N][2];

    component xw1 = MatrixVectorMultiSign(M, N, d, d);
    component xw2 = MatrixVectorMultiSignX(N, M, d, d*2+5);
    component sgv = SigmoidVector(M, d+d);
    component va = VectorAdd(M, d*2+5);
    component us[M];

    // XW
    for (var i = 0; i < N; i++) {
        xw1.W[i][0] <== W[i][0];
        xw1.W[i][1] <== W[i][1];
    }

    for (var i = 0; i < M; i++) {
        for (var j = 0; j < N; j++) {
            xw1.X[i][j][0] <== X[i][j][0];
            xw1.X[i][j][1] <== X[i][j][1];
        }
    }

    // sigmoid(XW)
    for (var i = 0; i < M; i++) {
        sgv.X[i] <== xw1.P[i][0];
    }

    // Y - sigmoid(XW)
    for (var i = 0; i < M; i++) {
        us[i] = UnSign();
        us[i].in <== Y[i][0];
        us[i].sign <== Y[i][1];

        va.L[i] <== us[i].out;
        va.R[i] <== -sgv.S[i][0];
    }

    // X'(Y - sigmoid(XW))
    for (var i = 0; i < M; i++) {
        xw2.W[i] <== va.S[i][0];
        d*2 + 5 === va.S[i][1];
    }

    for (var i = 0; i < N; i++) {
        for (var j = 0; j < M; j++) {
            xw2.X[i][j][0] <== X[j][i][0];
            xw2.X[i][j][1] <== X[j][i][1];
        }
    }

    for (var i = 0; i < N; i++) {
        G[i][0] <== xw2.P[i][0];
        G[i][1] <== xw2.P[i][1];
    }    

}

template G128(N, d) {
    signal input X[128][N][2];
    signal input W[N][2];
    signal input Y[128][2];
    signal output G[N][2];
    signal output hash;
    signal output root;

    component gradient = Gradient(128, N, d);
    component H = VectorHash(N);
    component MR = MerkleMatrix128(N+1);

    for (var i = 0; i < 128; i++) {
        gradient.Y[i][0] <== Y[i][0];
        gradient.Y[i][1] <== Y[i][1];

        for (var j = 0; j < N; j++) {
            gradient.X[i][j][0] <== X[i][j][0];
            gradient.X[i][j][1] <== X[i][j][1];
        }
    }

    for (var i = 0; i < N; i++) {
        gradient.W[i][0] <== W[i][0];
        gradient.W[i][1] <== W[i][1];
    }

    for (var i = 0; i < N; i++) {
        G[i][0] <== gradient.G[i][0];
        G[i][1] <== gradient.G[i][1];
    }

    // hash(W)
    for (var i = 0; i < N; i++) {
        H.in[i][0] <== W[i][0];
        H.in[i][1] <== W[i][1];
    }

    hash <== H.out;

    // MerkeRoot(X|Y)
    for (var i = 0; i < 128; i++) {
        for (var j = 0; j < N; j++) {
            MR.X[i][j][0] <== X[i][j][0];
            MR.X[i][j][1] <== X[i][j][1];
        }
        MR.X[i][N][0] <== Y[i][0];
        MR.X[i][N][1] <== Y[i][1];
    }

    root <== MR.out;
}

//  component main = Gradient(32, 3, 8);

