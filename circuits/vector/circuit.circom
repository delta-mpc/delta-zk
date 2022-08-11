pragma circom 2.0.0;

include "../float/circuit.circom";

template VectorAdd(N, deci) {
    signal input L[N][2];
    signal input R[N][2];
    signal output S[N][2];

    component fa[N];

    for (var i = 0; i < N; i++) {
        fa[i] = FloatAddSignSimple();
        fa[i].l[0] <== L[i][0];
        fa[i].l[1] <== deci;
        fa[i].l[2] <== L[i][1];

        fa[i].r[0] <== R[i][0];
        fa[i].r[1] <== deci;
        fa[i].r[2] <== R[i][1];

        S[i][0] <== fa[i].s[0];
        S[i][1] <== fa[i].s[1];
    }
}

template InnerProduct(N, deci) {
    signal input X[N][2];
    signal input W[N][2];
    signal output p[2];

    component fm[N];
    component fa[N];

    for (var i = 0; i < N; i++) {
        fm[i] = FloatMultiSign();
        fm[i].l[0] <== X[i][0];
        fm[i].l[1] <== deci;
        fm[i].l[2] <== X[i][1];
        fm[i].r[0] <== W[i][0];
        fm[i].r[1] <== deci;
        fm[i].r[2] <== W[i][1];

        fa[i] = FloatAddSimple();
        fa[i].r[0] <== fm[i].p[0];
        fa[i].r[1] <== fm[i].p[1];
    }

    fa[0].l[0] <== 0;
    fa[0].l[1] <== deci*2;

    for (var i = 1; i < N; i++) {
        fa[i].l[0] <== fa[i-1].s[0];
        fa[i].l[1] <== fa[i-1].s[1];
    }

    p[0] <== fa[N-1].s[0];
    p[1] <== fa[N-1].s[1];
}

component main = InnerProduct(10, 4);
