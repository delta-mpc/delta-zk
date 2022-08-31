include "../../node_modules/circomlib/circuits/mimc.circom";
include "../sign/circuit.circom";

template Merkle2() {
    signal input in[2];
    signal output out;
    component H = MultiMiMC7(2, 13);

    H.in[0] <== in[0];
    H.in[1] <== in[1];
    H.k <== 2;

    out <== H.out;
}

template Merkle4() {
    signal input in[4];
    signal output out;

    component H0 = Merkle2();
    component H1 = Merkle2();
    component H2 = Merkle2();
    

    for (var i = 0; i < 2; i++) {
        H1.in[i] <== in[i];
        H2.in[i] <== in[i+2];
    }

    H0.in[0] <== H1.out;
    H0.in[1] <== H2.out;

    out <== H0.out;
}

template Merkle8() {
    signal input in[8];
    signal output out;

    component H0 = Merkle2();
    component H1 = Merkle4();
    component H2 = Merkle4();
    
    for (var i = 0; i < 4; i++) {
        H1.in[i] <== in[i];
        H2.in[i] <== in[i+4];
    }

    H0.in[0] <== H1.out;
    H0.in[1] <== H2.out;
    out <== H0.out;
}

template Merkle16() {
    signal input in[16];
    signal output out;

    component H0 = Merkle2();
    component H1 = Merkle8();
    component H2 = Merkle8();
    
    for (var i = 0; i < 8; i++) {
        H1.in[i] <== in[i];
        H2.in[i] <== in[i+8];
    }

    H0.in[0] <== H1.out;
    H0.in[1] <== H2.out;
    out <== H0.out;
}

template Merkle32() {
    signal input in[32];
    signal output out;
    
    component H0 = Merkle2();
    component H1 = Merkle16();
    component H2 = Merkle16();

    for (var i = 0; i < 16; i++) {
        H1.in[i] <== in[i];
        H2.in[i] <== in[i+16];
    }

    H0.in[0] <== H1.out;
    H0.in[1] <== H2.out;
    out <== H0.out;
}

template Merkle64() {
    signal input in[64];
    signal output out;

    component H0 = Merkle2();
    component H1 = Merkle32();
    component H2 = Merkle32();
    
    for (var i = 0; i < 32; i++) {
        H1.in[i] <== in[i];
        H2.in[i] <== in[i+32];
    }

    H0.in[0] <== H1.out;
    H0.in[1] <== H2.out;
    out <== H0.out;
}

template Merkle128() {
    signal input in[128];
    signal output out;

    component H0 = Merkle2();
    component H1 = Merkle64();
    component H2 = Merkle64();

    for (var i = 0; i < 64; i++) {
        H1.in[i] <== in[i];
        H2.in[i] <== in[i+64];
    }

    H0.in[0] <== H1.out;
    H0.in[1] <== H2.out;
    out <== H0.out;
}

// 向量的mimc hash
template VectorHash(N) {
    signal input in[N][2];
    signal output out;

    component us[N];
    component H = MultiMiMC7(N, 13);

    for (var i = 0; i < N; i++) {
        us[i] = UnSign();
        us[i].in <== in[i][0];
        us[i].sign <== in[i][1];

        H.in[i] <== us[i].out;
    }

    H.k <== 2;
    out <== H.out;
}

template MerkleMatrix128(N) {
    signal input X[128][N][2];
    signal output out;

    component vh[128];
    component mt = Merkle128();

    for (var i = 0; i < 128; i++) {
        vh[i] = VectorHash(N);
        for (var j = 0; j < N; j++) {
            vh[i].in[j][0] <== X[i][j][0];
            vh[i].in[j][1] <== X[i][j][1];
        }
        mt.in[i] <== vh[i].out;
    }

    out <== mt.out;
}

// component main = MerkleMatrix128(3);