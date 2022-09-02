# delta-zk

The zero knowledge proof system used in Delta.

## Dependency

1. Docker
2. docker-compose(optional)
3. nodejs && yarn
4. [snarksjs](https://github.com/iden3/snarkjs)  

    ```shell
    npm install -g snarkjs@latest
    ```

5. [circom (v2.0.6)](https://github.com/iden3/circom/releases/tag/v2.0.6)
    
    ```shell
    wget https://github.com/iden3/circom/releases/download/v2.0.6/circom-linux-amd64 /usr/local/bin/circom
    ```

    ```shell
    chmod +x /usr/local/bin/circom
    ```

## Setup

> All key files will be generated under directory ``circuits/main/${input_size}``

## setup with docker

```shell
docker run --rm -it --name delta-zk-setup -v ${PWD}/circuits/main:/app/circuits/main deltampc/delta-zk:dev yarn setup ${input_size}
```

## setup with yarn

```shell
# download snarkjs Ptau file
wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_20.ptau ./ptau/pot_final.ptau
```

```shell
yarn setup ${input_size}
```

## Build

### build with docker

```shell
docker compose build
```

or

```shell
docker build -t deltampc/delta-zk:dev .
```

### build with yarn

```shell
yarn install
```

## Run gRPC service

### run with docker

```shell
docker compose up -d
```

or

```shell
docker run --name delta-zk -p 4500:4500 -d deltampc/delta-zk:dev
```

### run with yarn

```shell
yarn server
```
