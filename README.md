# tdlib-java

This repository provides the following pre-built files to simplify the development of Java Telegram clients:

* `tdlib.jar`
* `libtdjni.so`

A `module-info.class` file is added to the generated `tdlib.jar` file, in order to support Java module system.

Java 21 is used for the build.

## Installation

Download the files from the [latest release](https://github.com/ombra-chat/tdlib-java/releases).

Install the libtdjni library:

```sh
sudo cp libtdjni.so /usr/lib64
```

Install the jar via Maven using the following command:

```sh
mvn install:install-file -Dfile=/path/to/tdlib.jar -DgroupId=org.drinkless -DartifactId=tdlib -Dversion=1.8.48 -Dpackaging=jar
```

Then you can include it in your pom.xml and use it as usual:

```xml
<dependency>
    <groupId>org.drinkless</groupId>
    <artifactId>tdlib</artifactId>
    <version>1.8.48</version>
</dependency>
```

## How it works

The Dockerfile uses the instruction from https://tdlib.github.io/td/build.html?language=Java.

All the generated classes, except the example ones, are packed to a jar file.

## License

This repository provides a repackaging of [tdlib](https://github.com/tdlib/td), that is released with Boost Software License - copyright Aliaksei Levin (levlam@telegram.org), Arseny Smirnov (arseny30@gmail.com) 2014-2025.
