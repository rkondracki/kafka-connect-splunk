FROM anapsix/alpine-java:8_jdk
ARG ssh_prv_key
ARG ssh_pub_key
ENV kafkaversion=2.5.0

RUN apk update && apk upgrade && apk add git && apk add openssh && apk add openssl && apk add python && apk add gcc && apk add python-dev && apk add musl-dev && apk add linux-headers

RUN wget -q https://bootstrap.pypa.io/get-pip.py -P / && python get-pip.py && pip install requests && pip install psutil

RUN wget -q http://apache.claz.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -P /bin && cd /bin && tar xzf apache-maven-3.6.3-bin.tar.gz

ENV PATH=${PATH}:/bin/apache-maven-3.6.3/bin

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo $ssh_prv_key > /root/.ssh/id_rsa && \
    echo $ssh_pub_key > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

RUN mkdir -p /kafka-connect/kafka
RUN mkdir /kafka-connect/logs

RUN wget -q http://apache.mirrors.hoobly.com/kafka/${kafkaversion}/kafka_2.12-${kafkaversion}.tgz -P / && tar -xf kafka_2.12-2.5.0.tgz -C /kafka-connect/kafka --strip-components 1 && rm -f kafka_2.12-${kafkaversion}.tgz

WORKDIR /kafka-connect

ADD run_kafka_connect.sh /kafka-connect/run_kafka_connect.sh

EXPOSE 9092 8083
CMD ["/bin/bash", "-c", "/kafka-connect/run_kafka_connect.sh"]
