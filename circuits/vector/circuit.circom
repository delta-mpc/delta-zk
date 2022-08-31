pragma circom 2.0.6;

include "../../node_modules/circomlib/circuits/mimc.circom";
include "../float/circuit.circom";

// 向量加法，输入无符号，输出无符号
template VectorAdd(N, d) {
    signal input L[N];
    signal input R[N];
    signal output S[N][2];

    component fa[N];

    for (var i = 0; i < N; i++) {
        fa[i] = FloatAddSimple();
        fa[i].l[0] <== L[i];
        fa[i].l[1] <== d;

        fa[i].r[0] <== R[i];
        fa[i].r[1] <== d;

        S[i][0] <== fa[i].s[0];
        S[i][1] <== fa[i].s[1];
    }
}

// 向量加法，输入有符号，输出无符号
template VectorAddSign(N, d) {
    signal input L[N][2];
    signal input R[N][2];
    signal output S[N][2];

    component fa[N];

    for (var i = 0; i < N; i++) {
        fa[i] = FloatAddSignSimple();
        fa[i].l[0] <== L[i][0];
        fa[i].l[1] <== d;
        fa[i].l[2] <== L[i][1];

        fa[i].r[0] <== R[i][0];
        fa[i].r[1] <== d;
        fa[i].r[2] <== R[i][1];

        S[i][0] <== fa[i].s[0];
        S[i][1] <== fa[i].s[1];
    }
}

// 矩阵乘向量，输入有符号，输出无符号
template MatrixVectorMultiSign(M, N, dX, dW) {
    signal input X[M][N][2];
    signal input W[N][2];
    signal output P[M][2];

    component ips[M];

    for (var i = 0; i < M; i++) {
        ips[i] = InnerProductSign(N, dX, dW);
        for (var j = 0; j < N; j++) {
            ips[i].L[j][0] <== X[i][j][0];
            ips[i].L[j][1] <== X[i][j][1];
            ips[i].R[j][0] <== W[j][0];
            ips[i].R[j][1] <== W[j][1];
        }
        P[i][0] <== ips[i].p[0];
        P[i][1] <== ips[i].p[1];
        P[i][1] === dX + dW;
    }
}

// 矩阵乘向量，输入X有符号，W无符号，输出无符号
template MatrixVectorMultiSignX(M, N, dX, dW) {
    signal input X[M][N][2];
    signal input W[N];
    signal output P[M][2];

    component ips[M];

    for (var i = 0; i < M; i++) {
        ips[i] = InnerProductSignL(N, dX, dW);
        for (var j = 0; j < N; j++) {
            ips[i].L[j][0] <== X[i][j][0];
            ips[i].L[j][1] <== X[i][j][1];
            ips[i].R[j] <== W[j];
        }
        P[i][0] <== ips[i].p[0];
        P[i][1] <== ips[i].p[1];
        P[i][1] === dX + dW;
    }
}

// 矩阵乘向量，输入无符号，输出无符号
template MatrixVectorMulti(M, N, dX, dW) {
    signal input X[M][N];
    signal input W[N];
    signal output P[M][2];

    component ips[M];

    for (var i = 0; i < M; i++) {
        ips[i] = InnerProduct(N, dX, dW);
        for (var j = 0; j < N; j++) {
            ips[i].L[j] <== X[i][j];
            ips[i].R[j] <== W[j];
        }
        P[i][0] <== ips[i].p[0];
        P[i][1] <== ips[i].p[1];
        P[i][1] === dX + dW;
    }
}

// 向量内积，输入无符号，输出无符号
template InnerProduct(N, dL, dR) {
    signal input L[N];
    signal input R[N];
    signal output p[2];

    component fm[N];
    component fa[N];

    for (var i = 0; i < N; i++) {
        fm[i] = FloatMulti();
        fm[i].l[0] <== L[i];
        fm[i].l[1] <== dL;
        fm[i].r[0] <== R[i];
        fm[i].r[1] <== dR;

        fa[i] = FloatAddSimple();
        fa[i].r[0] <== fm[i].p[0];
        fa[i].r[1] <== fm[i].p[1];
    }

    fa[0].l[0] <== 0;
    fa[0].l[1] <== dL + dR;

    for (var i = 1; i < N; i++) {
        fa[i].l[0] <== fa[i-1].s[0];
        fa[i].l[1] <== fa[i-1].s[1];
    }

    p[0] <== fa[N-1].s[0];
    p[1] <== fa[N-1].s[1];

    p[1] === dL + dR;
}

// 向量内积，输入有符号，输出无符号
template InnerProductSign(N, dL, dR) {
    signal input L[N][2];
    signal input R[N][2];
    signal output p[2];

    component ip = InnerProduct(N, dL, dR);
    component us[N][2];

    for (var i = 0; i < N; i++) {
        us[i][0] = UnSign();
        us[i][0].in <== L[i][0];
        us[i][0].sign <== L[i][1];
        us[i][1] = UnSign();
        us[i][1].in <== R[i][0];
        us[i][1].sign <== R[i][1];

        ip.L[i] <== us[i][0].out;
        ip.R[i] <== us[i][1].out;
    }

    p[0] <== ip.p[0];
    p[1] <== ip.p[1];

    p[1] === dL + dR;
}

// 向量内积，输入L有符号,R无符号，输出无符号
template InnerProductSignL(N, dL, dR) {
    signal input L[N][2];
    signal input R[N];
    signal output p[2];

    component ip = InnerProduct(N, dL, dR);
    component us[N];

    for (var i = 0; i < N; i++) {
        us[i] = UnSign();
        us[i].in <== L[i][0];
        us[i].sign <== L[i][1];

        ip.L[i] <== us[i].out;
        ip.R[i] <== R[i];
    }

    p[0] <== ip.p[0];
    p[1] <== ip.p[1];

    p[1] === dL + dR;
}

// component main = MatrixVectorMultiSign(5, 5, 4, 4);
