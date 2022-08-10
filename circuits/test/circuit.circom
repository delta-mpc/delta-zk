pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";


template Test() {
    signal input in[2];
    signal output out;

    out <== in[0] - in[1];
}

component main = Test();
