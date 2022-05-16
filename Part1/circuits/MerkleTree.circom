pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    // var nthItem = 2 ** 4;
    // var levels = 4;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component hashedLayers[n] = Poseidon(2); //We declare the levels of hashedLayers we want to create
    
    // for(var level = n; level >= 0; level--) {
    //     hashedLayers[level] = Poseidon(2);
    for(var i = 0; i < n; i++) {
        hashedLayers[i].inputs[i] <== i == 0 ?leaves[i] : hashedLayers[i + 1].out;
    }
    
    root <== n > 0 ? hashedLayers[0].out : leaves[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashedLayers[n];
    component mux[n];

    signal hashTray[n + 1];
    hashTray[0] <== leaf; //We only need copy the leaf hence we store it in first spot.

    for(var i = 0; i < n; i++) {
        path_index[i] * (1 - path_index[i]) === 0;
        hashedLayers[i] = Poseidon(2);
        mux[i] = MultiMux1(2);

        mux[i].c[0][0] <== hashTray[i];
        mux[i].c[0][1] <== path_elements[i];

        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== hashTray[i];

        mux[i].s <== path_index[i];

        hashedLayers[i].inputs[0] <== mux[i].out[0];
        hashedLayers[i].inputs[1] <== mux[i].out[1];

        hashTray[i + 1] <== hashedLayers[i].out;
    }
    root <== hashTray[n];
}