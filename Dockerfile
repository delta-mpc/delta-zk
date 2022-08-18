FROM deltampc/delta-zk:base
WORKDIR /app
COPY . .
RUN yarn
