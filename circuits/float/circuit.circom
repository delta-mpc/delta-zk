pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";

template FloatMulti() {
    signal input l[2];
    signal input r[2];
    signal output p[2];

    p[0] <== l[0] * r[0];
    p[1] <== l[1] + r[1];
}

template FloatAdd() {
    signal input l[2];
    signal input r[2];
    signal input sign;
    signal output s[2];
    signal intern;
    signal fac;

    component gt = GreaterThan(5);
    component swi = Switcher();
    component swd = Switcher();
    component sw = Switcher();
    component isz = IsZero();

    gt.in[0] <== l[1];
    gt.in[1] <== r[1];

    swi.sel <== gt.out;
    swi.L <== l[1];
    swi.R <== r[1];

    var d = swi.outR - swi.outL;
    fac <-- 10**d;
    fac*0 === 0;

    swd.sel <== gt.out;
    swd.L <== fac;
    swd.R <== 1;
    intern <== swd.outL * l[0];

    isz.in <== sign;
    sw.sel <== isz.out;
    sw.L <== intern - swd.outR * r[0];
    sw.R <== intern + swd.outR * r[0];

    s[0] <== sw.outL;
    s[1] <== swi.outR;
}
