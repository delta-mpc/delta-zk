pragma circom 2.0.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";
include "../float/circuit.circom";
include "../sign/circuit.circom";

template Sigmoid0_1(d) {
    signal input x;
    signal output s[2];

    component fm = FloatMulti();
    component fa = FloatAddSimple();

    fm.l[0] <== 25000;
    fm.l[1] <== 5;
    fm.r[0] <== x;
    fm.r[1] <== d;

    fa.l[0] <== fm.p[0];
    fa.l[1] <== fm.p[1];
    fa.r[0] <== 5*(10**(d+4));
    fa.r[1] <== d+5;

    s[0] <== fa.s[0];
    s[1] <== fa.s[1];
}

template Sigmoid1_2(d) {
    signal input x;
    signal output s[2];

    component fm = FloatMulti();
    component fa = FloatAddSimple();

    fm.l[0] <== 12500;
    fm.l[1] <== 5;
    fm.r[0] <== x;
    fm.r[1] <== d;

    fa.l[0] <== fm.p[0];
    fa.l[1] <== fm.p[1];
    fa.r[0] <== 625*(10**(d+2));
    fa.r[1] <== d+5;

    s[0] <== fa.s[0];
    s[1] <== fa.s[1];
}

template Sigmoid2_5(d) {
    signal input x;
    signal output s[2];

    component fm = FloatMulti();
    component fa = FloatAddSimple();

    fm.l[0] <== 3125;
    fm.l[1] <== 5;
    fm.r[0] <== x;
    fm.r[1] <== d;

    fa.l[0] <== fm.p[0];
    fa.l[1] <== fm.p[1];
    fa.r[0] <== 84375 * (10**d);
    fa.r[1] <== d+5;

    s[0] <== fa.s[0];
    s[1] <== fa.s[1];
}

template Switcher2() {
    signal input sel;
    signal input L[2];
    signal input R[2];
    signal output outL[2];
    signal output outR[2];
    component sw[2];

    sw[0] = Switcher();
    sw[1] = Switcher();

    sw[0].sel <== sel;
    sw[1].sel <== sel;

    sw[0].L <== L[0];
    sw[0].R <== R[0];
    sw[1].L <== L[1];
    sw[1].R <== R[1];

    outL[0] <== sw[0].outL;
    outL[1] <== sw[1].outL;
    outR[0] <== sw[0].outR;
    outR[1] <== sw[1].outR;
}

template Sigmoid(d) {
    assert(d >= 3);
    signal input x;
    signal input sign;
    signal output s[2];

    component gt1 = GreaterThan(36);
    component gt2 = GreaterThan(36);
    component gt3 = GreaterThan(36);
    component isz = IsZero();
    component sw1 = Switcher2();
    component sw2 = Switcher2();
    component sw3 = Switcher2();
    component sw4 = Switcher2();
    component sg1 = Sigmoid0_1(d);
    component sg2 = Sigmoid1_2(d);
    component sg3 = Sigmoid2_5(d);
    component fs = FloatAddSimple();

    // 判断x的区间
    var fac = 10**(d-3);
    gt1.in[0] <== x;
    gt1.in[1] <== 1000*fac;
    gt2.in[0] <== x;
    gt2.in[1] <== 2375*fac;
    gt3.in[0] <== x;
    gt3.in[1] <== 5000*fac;

    // 计算不同区间内的sigmoid
    sg1.x <== x;
    sg2.x <== x;
    sg3.x <== x;

    // 使用switcher获得对应区间的函数值
    sw1.sel <== gt1.out;
    sw1.L[0] <== sg1.s[0];
    sw1.L[1] <== sg1.s[1];
    sw1.R[0] <== sg2.s[0];
    sw1.R[1] <== sg2.s[1];

    sw2.sel <== gt2.out;
    sw2.L[0] <== sw1.outL[0];
    sw2.L[1] <== sw1.outL[1];
    sw2.R[0] <== sg3.s[0];
    sw2.R[1] <== sg3.s[1];

    sw3.sel <== gt3.out;
    sw3.L[0] <== sw2.outL[0];
    sw3.L[1] <== sw2.outL[1];
    sw3.R[0] <== 10**(d + 5);
    sw3.R[1] <== d + 5;

    // 处理负数
    fs.l[0] <== 10**(d + 5);
    fs.l[1] <== d + 5;
    fs.r[0] <== -sw3.outL[0];
    fs.r[1] <== sw3.outL[1];

    isz.in <== sign;
    sw4.sel <== isz.out;
    sw4.L[0] <== fs.s[0];
    sw4.L[1] <== fs.s[1];
    sw4.R[0] <== sw3.outL[0];
    sw4.R[1] <== sw3.outL[1];

    s[0] <== sw4.outL[0];
    s[1] <== sw4.outL[1];
    s[1] === d + 5;
}

// 计算向量的sigmoid，输入无符号，输出无符号
template SigmoidVector(N, d) {
    signal input X[N];
    signal output S[N][2];

    component sg[N];
    component sn[N];

    for (var i = 0; i < N; i++) {
        sn[i] = Sign();
        sn[i].in <== X[i];

        sg[i] = Sigmoid(d);
        sg[i].x <== sn[i].out;
        sg[i].sign <== sn[i].sign;

        S[i][0] <== sg[i].s[0];
        S[i][1] <== sg[i].s[1];
    }
}

// component main = SigmoidVector(5, 4);
// component main = Sigmoid(4);
