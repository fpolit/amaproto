FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt -y update && apt -y full-upgrade
RUN apt -y install gcc g++ python3.8 python3.8-dev libprotobuf-dev # required dependencies
RUN apt -y install python3-setuptools python3-pip git make cmake sudo # build dependencies

# python protobuf generation
COPY requirements.txt .
RUN python3 -m pip install -r requirements.txt

RUN useradd -m -u 970 jenkins && echo "jenkins:jenkins" | chpasswd
RUN echo "jenkins ALL=(root) NOPASSWD: $(which make)" >> /etc/sudoers
RUN visudo --check

USER jenkins
