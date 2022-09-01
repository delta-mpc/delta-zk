FROM node:16.16.0-buster-slim
WORKDIR /app
ADD https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_20.ptau /app/ptau/pot_final.ptau
ADD https://github.com/iden3/circom/releases/download/v2.0.6/circom-linux-amd64 /usr/local/bin/circom
COPY . .
RUN chmod +x /usr/local/bin/circom && apt-get update \
    && apt-get install -y --no-install-recommends make \
    && rm -rf /var/lib/apt/lists/* && yarn
