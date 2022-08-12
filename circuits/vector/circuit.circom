pragma circom 2.0.0;

include "../float/circuit.circom";

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
template MatrixVectorMulti(M, N, d) {
    signal input X[M][N][2];
    signal input W[N][2];
    signal output P[N][2];

    component ips[M];

    for (var i = 0; i < M; i++) {
        ips[i] = InnerProductSign(N, d, d);
        for (var j = 0; j < N; j++) {
            ips[i].L[j][0] <== X[i][j][0];
            ips[i].L[j][1] <== X[i][j][1];
            ips[i].R[j][0] <== W[j][0];
            ips[i].R[j][1] <== W[j][1];
        }
        P[i][0] <== ips[i].p[0];
        P[i][1] <== ips[i].p[1];
        P[i][1] === d * 2;
    }
}

// 向量内积，输入有符号，输出无符号
template InnerProductSign(N, dL, dR) {
    signal input L[N][2];
    signal input R[N][2];
    signal output p[2];

    component fm[N];
    component fa[N];

    for (var i = 0; i < N; i++) {
        fm[i] = FloatMultiSign();
        fm[i].l[0] <== L[i][0];
        fm[i].l[1] <== dL;
        fm[i].l[2] <== L[i][1];
        fm[i].r[0] <== R[i][0];
        fm[i].r[1] <== dR;
        fm[i].r[2] <== R[i][1];

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

component main = MatrixVectorMulti(5, 5, 4);
// component main = InnerProductSign(10, 4);
