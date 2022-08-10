pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";

template Sign() {
    signal input in;
    signal output out;
    signal output sign;
    component lt = LessThan(252);
    component sw = Switcher();

    lt.in[0] <== in;
    lt.in[1] <== 0;

    sw.sel <== lt.out;
    sw.L <== in;
    sw.R <== -in;

    out <== sw.outL;
    sign <== lt.out;
}

template FloatMulti() {
    signal input l[2];
    signal input r[2];
    signal output p[2];

    p[0] <== l[0] * r[0];
    p[1] <== l[1] + r[1];
}

template FloatSumSimple() {
    signal input l[2];
    signal input r[2];
    signal input op;
    signal output s[2];

    component sw = Switcher();
    component isz = IsZero();

    l[1] === r[1];

    // 处理减法
    isz.in <== op;
    sw.sel <== isz.out;
    sw.L <== l[0] - r[0];
    sw.R <== l[0] + r[0];

    s[0] <== sw.outL;
    s[1] <== l[1];
}

template FloatSum() {
    signal input l[2];
    signal input r[2];
    signal input op;
    signal output s[2];
    signal left;
    signal right;

    component gtd = GreaterThan(5);
    component swd = Switcher();
    component swf = Switcher();
    component sw = Switcher();
    component isz = IsZero();

    // 计算精度差
    gtd.in[0] <== l[1];
    gtd.in[1] <== r[1];

    swd.sel <== gtd.out;
    swd.L <== l[1];
    swd.R <== r[1];

    var d = swd.outR - swd.outL;
    var fac = 10**d;

    // 计算对齐精度后的两个操作数
    swf.sel <== gtd.out;
    swf.L <-- fac;
    swf.R <== 1;
    left <== swf.outL * l[0];
    right <== swf.outR * r[0];

    // 处理减法
    isz.in <== op;
    sw.sel <== isz.out;
    sw.L <== left - right;
    sw.R <== left + right;

    s[0] <== sw.outL;
    s[1] <== swd.outR;
}

template FloatSumSign() {
    signal input l[2];
    signal input r[2];
    signal input op;
    signal output s[2];
    signal output sign;

    component fs = FloatSum();
    component si = Sign();

    fs.l[0] <== l[0];
    fs.l[1] <== l[1];
    fs.r[0] <== r[0];
    fs.r[1] <== r[1];
    fs.op <== op;

    si.in <== fs.s[0];

    s[0] <== si.out;
    s[1] <== fs.s[1];
    sign <== si.sign;
}

// component main = FloatSumSign();
