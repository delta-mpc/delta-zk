BASE=circuits
DIR ?= gradient
WORKDIR=$(BASE)/$(DIR)

# compile
compile $(WORKDIR)/circuit.r1cs $(WORKDIR)/circuit.wasm:$(WORKDIR)/circuit.circom
	cd $(WORKDIR) && \
	circom circuit.circom --r1cs --wasm --sym --inspect && \
	# snarkjs r1cs info circuit.r1cs && \
	mv ./circuit_js/circuit.wasm ./circuit.wasm && \
	rm -rf ./circuit_js

# plonk setup
setup $(WORKDIR)/circuit_final.zkey:./ptau/pot_final.ptau compile
	# snarkjs powersoftau verify pot_final.ptau
	snarkjs plonk setup $(WORKDIR)/circuit.r1cs ./ptau/pot_final.ptau $(WORKDIR)/circuit_final.zkey

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

docker-setup:
	docker run --rm -it --name delta-zk-setup -v ${PWD}/circuits/main:/app/circuits/main deltampc/delta-zk:dev yarn setup 3

docker-run:
	docker run --name delta-zk -v ${PWD}/circuits/main:/app/circuits/main -p 4500:4500 -d deltampc/delta-zk:dev