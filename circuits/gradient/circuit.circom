pragma circom 2.0.6;

include "../vector/circuit.circom";
include "../sigmoid/circuit.circom";

// 计算梯度，输入有符号，输出无符号
template G(M, N, d) {
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

    // // Y - sigmoid(XW)
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

component main {public [W]}= G(10, 5, 4);
