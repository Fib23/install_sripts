#!/bin/bash
apt install -y gnupg2 git && \
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - && \
echo "deb https://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list && \
apt-get update && \
apt install -y openjdk-11-jdk && \
apt install -y jenkins;