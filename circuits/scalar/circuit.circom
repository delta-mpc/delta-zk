pragma circom 2.0.0;

include "../float/circuit.circom";

template ScalarProduct(N, deci) {
    signal input x[N];
    signal input w[N];
    signal input op[N];
    signal output sp[2];
    signal output sign;

    component fm[N];
    component fa[N];
    component s = Sign();

    for (var i = 0; i < N; i++) {
        fm[i] = FloatMulti();
        fm[i].l[0] <== x[i];
        fm[i].l[1] <== deci;
        fm[i].r[0] <== w[i];
        fm[i].r[1] <== deci;

        fa[i] = FloatSumSimple();
        fa[i].op <== op[i];
        fa[i].r[0] <== fm[i].p[0];
        fa[i].r[1] <== fm[i].p[1];
    }

    fa[0].l[0] <== 0;
    fa[0].l[1] <== deci*2;

    for (var i = 1; i < N; i++) {
        fa[i].l[0] <== fa[i-1].s[0];
        fa[i].l[1] <== fa[i-1].s[1];
    }

    s.in <== fa[N-1].s[0];
    sp[0] <== s.out;
    sp[1] <== fa[N-1].s[1];
    sign <== s.sign;
}

component main = ScalarProduct(10, 4);
