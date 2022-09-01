# delta-zk

The zero knowledge proof system used in Delta.

## Dependency

1. Docker
2. docker-compose(optional)
3. nodejs & yarn
4. [snarksjs](https://github.com/iden3/snarkjs)
5. [circom](https://github.com/iden3/circom)

## Setup

```yarn setup ${input_size}```

All key files will be generated under directory ```circuits/main/${input_size}```

## Build

### build with docker

```docker compose build```
or
```docker build -t deltampc/delta-zk:dev .```

### build with yarn

```yarn install```

## Run gRPC server

### run with docker

```docker compose up -d```
or
```docker run --name delta-zk -p 4500:4500 -d deltampc/delta-zk:dev```

### run with yarn

```yarn server```
