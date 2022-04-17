FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y full-upgrade
RUN apt -y install g++ python3.8 libprotoc-dev # required dependencies
RUN apt -y install python3-pip make cmake protobuf-compiler # build dependencies

# python protobuf generation
RUN python3 -m pip install grpcio grpcio-tools
