FROM debian:12 AS builder-stage

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y git make git zlib1g-dev libssl-dev gperf php-cli cmake default-jdk g++

RUN git clone https://github.com/tdlib/td.git

WORKDIR /td

# 1.8.48
RUN git checkout b8b08b02dbbc0c05e7129e2f306c636c5b8ec04f

RUN mkdir build
WORKDIR /td/build

RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../example/java/td -DTD_ENABLE_JNI=ON ..

RUN cmake --build . --target install

RUN mkdir /td/example/java/build
WORKDIR /td/example/java/build

RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../../../tdlib -DTd_DIR:PATH=$(readlink -e ../td/lib/cmake/Td) ..

RUN cmake --build . --target install

WORKDIR /td/tdlib/bin

# creating jar file
RUN rm -Rf org/drinkless/tdlib/example
RUN mkdir jar
RUN mv org/ jar/
RUN jar cf tdlib.jar -C jar .

# patching jar to add module-info.java
COPY module-info.java /td/tdlib/bin/
RUN javac --patch-module org.drinkless.tdlib=tdlib.jar module-info.java
RUN jar uf tdlib.jar module-info.class

# copying the files to the target directory
FROM scratch
COPY --from=builder-stage /td/tdlib/bin/tdlib.jar /
COPY --from=builder-stage /td/tdlib/bin/libtdjni.so /
