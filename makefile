BASE=circuits
DIR ?= main
WORKDIR=$(BASE)/$(DIR)

# compile
compile $(WORKDIR)/circuit.r1cs $(WORKDIR)/circuit.wasm:$(WORKDIR)/circuit.circom
	cd $(WORKDIR) && \
	circom circuit.circom --r1cs --wasm --sym --inspect && \
	# snarkjs r1cs info circuit.r1cs && \
	mv ./circuit_js/circuit.wasm ./circuit.wasm && \
	rm -rf ./circuit_js

# plonk setup
setup $(WORKDIR)/circuit_final.zkey:pot_final.ptau compile
	# snarkjs powersoftau verify pot_final.ptau
	snarkjs plonk setup $(WORKDIR)/circuit.r1cs pot_final.ptau $(WORKDIR)/circuit_final.zkey

# export vk
zkev $(WORKDIR)/verification_key.json:setup
	cd $(WORKDIR) && \
	snarkjs zkev circuit_final.zkey verification_key.json

# plonk full prove
pkf:$(WORKDIR)/input.json setup
	cd $(WORKDIR) && \
	snarkjs pkf input.json circuit.wasm circuit_final.zkey proof.json public.json

# plonk verify
pkv:zkev pkf
	cd $(WORKDIR) && \
	snarkjs pkv verification_key.json public.json proof.json

js:
	cp snark/test.js $(WORKDIR) && \
	cd $(WORKDIR) && \
	node test.js

clean:
	cd $(WORKDIR) && \
	rm -f circuit.r1cs circuit.sym circuit.wasm circuit_final.zkey verification_key.json proof.json public.json
