pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";
include "../float/circuit.circom";

template Sigmoid0_1() {
    signal input x[2];
    signal output s[2];

    component fm = FloatMulti();
    component fa = FloatAdd();

    fm.l[0] <== 25;
    fm.l[1] <== 2;
    fm.r[0] <== x[0];
    fm.r[1] <== x[1];

    fa.l[0] <== fm.p[0];
    fa.l[1] <== fm.p[1];
    fa.r[0] <== 5;
    fa.r[1] <== 1;

    s[0] <== fa.s[0];
    s[1] <== fa.s[1];
}

template Sigmoid1_2() {
    signal input x[2];
    signal output s[2];

    component fm = FloatMulti();
    component fa = FloatAdd();

    fm.l[0] <== 125;
    fm.l[1] <== 3;
    fm.r[0] <== x[0];
    fm.r[1] <== x[1];

    fa.l[0] <== fm.p[0];
    fa.l[1] <== fm.p[1];
    fa.r[0] <== 625;
    fa.r[1] <== 3;

    s[0] <== fa.s[0];
    s[1] <== fa.s[1];
}

template Sigmoid2_5() {
    signal input x[2];
    signal output s[2];

    component fm = FloatMulti();
    component fa = FloatAdd();

    fm.l[0] <== 3125;
    fm.l[1] <== 5;
    fm.r[0] <== x[0];
    fm.r[1] <== x[1];

    fa.l[0] <== fm.p[0];
    fa.l[1] <== fm.p[1];
    fa.r[0] <== 84375;
    fa.r[1] <== 5;

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

template Sigmoid(deci) {
    assert(deci >= 3);
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
    component sg1 = Sigmoid0_1();
    component sg2 = Sigmoid1_2();
    component sg3 = Sigmoid2_5();
    component fs = FloatAdd();

    // 判断x的区间
    var fac = 10**(deci-3);
    gt1.in[0] <== x;
    gt1.in[1] <== 1000*fac;
    gt2.in[0] <== x;
    gt2.in[1] <== 2375*fac;
    gt3.in[0] <== x;
    gt3.in[1] <== 5000*fac;

    // 计算不同区间内的sigmoid
    sg1.x[0] <== x;
    sg1.x[1] <== 4;
    sg2.x[0] <== x;
    sg2.x[1] <== 4;
    sg3.x[0] <== x;
    sg3.x[1] <== 4;

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
    sw3.R[0] <== 1;
    sw3.R[1] <== 0;

    // 处理负数
    fs.l[0] <== 1;
    fs.l[1] <== 0;
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
}

component main = Sigmoid(4);
