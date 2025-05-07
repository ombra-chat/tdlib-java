#!/bin/sh

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <version> [architecture]"
  exit 1
fi

# Prepend "v" to version, if needed
version="$1"
if [ "${version#v}" = "$version" ]; then
  version="v$version"
fi

# without "v"
version_number="${version#v}"

# Default architecture is amd64 if not provided
if [ -z "$2" ]; then
  architecture="amd64"
else
  architecture="$2"
fi

echo $version
echo $version_number
echo $architecture

wget https://github.com/ombra-chat/tdlib-java/releases/download/$version/libtdjni-$version-$architecture.zip

wget https://github.com/ombra-chat/tdlib-java/releases/download/$version/tdlib-$version.jar

mvn install:install-file -Dfile=tdlib-$version.jar -DgroupId=org.drinkless -DartifactId=tdlib -Dversion=$version_number -Dpackaging=jar

unzip libtdjni-*.zip
sudo mv libtdjni.so /usr/lib64

rm libtdjni-*.zip
rm tdlib-*.jar
