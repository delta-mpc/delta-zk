pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";


template Test() {
    signal input in[2];
    signal output out;
    signal a;
    signal b;

    a <== -in[0];
    b <== a * in[1];
    out <== -b;
}

component main = Test();
