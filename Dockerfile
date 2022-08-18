FROM registry.cn-shanghai.aliyuncs.com/ybase/delta-zk:base
WORKDIR /app
COPY . .
RUN yarn
