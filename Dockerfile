FROM eclipse-temurin:21 AS builder-stage

RUN apt update && apt install -y git cmake clang-18 libc++-18-dev libc++abi-18-dev gperf zlib1g-dev libssl-dev php-cli

RUN git clone https://github.com/tdlib/td.git

WORKDIR /td

# 1.8.47
RUN git checkout a03a90470d6fca9a5a3db747ba3f3e4a465b5fe7

RUN mkdir build
WORKDIR /td/build

RUN CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-18 CXX=/usr/bin/clang++-18 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../example/java/td -DTD_ENABLE_JNI=ON ..

RUN cmake --build . --target install

RUN mkdir /td/example/java/build
WORKDIR /td/example/java/build

RUN CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-18 CXX=/usr/bin/clang++-18 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../../../tdlib -DTd_DIR:PATH=$(readlink -e ../td/lib/cmake/Td) ..

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
