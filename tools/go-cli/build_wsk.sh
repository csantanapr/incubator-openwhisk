#!/bin/bash

set -e

build_cli () {  
      echo "Building for OS '$4' and architecture '$2'" 
      export GOARCH=$2 
      export GOOS=$4 
      if [ $2 = arm ]; then 
          export GOARM=7 
        fi 
      pushd go-whisk-cli 
      go build -ldflags "-X main.CLI_BUILD_TIME=`date -u '+%Y-%m-%dT%H:%M:%S%:z'`" -v -o build/$1/$2/$3 main.go
      popd 
}

get_compressed_name() { 
    local product_name="OpenWhisk_CLI"
    if [ $2 = amd64 ]; then 
        comp_name="$product_name-$1" 
    elif [ $2 = 386 ]; then 
        comp_name="$product_name-$1-32bit" 
    else  
        comp_name="$product_name-$1-$2" 
    fi
    echo $comp_name; 
} 

compress_binaries() { 
    comp_name=$(get_compressed_name $1 $2)
    pushd go-whisk-cli/build/$1/$2 
    if [ $4 = tgz ]; then 
        echo "Compressing binary '$3' to '$comp_name.tgz'" 
        tar -cvzf $comp_name.tar.gz $3 
        rm -f $comp_name.tar 
    else 
        echo "Compressing binary '$3' to '$comp_name.zip'" 
        zip $comp_name.zip $3 
    fi && 
    popd 
} 

archs="386 amd64 arm" 
for arch in $archs; do 
    build_cli mac $arch wsk darwin 
    compress_binaries mac $arch wsk tgz 
done && 

archs="386 amd64 arm arm64" 
for arch in $archs; do 
    build_cli linux $arch wsk linux 
    compress_binaries linux $arch wsk tgz 
done 

archs="386 amd64" 
for arch in $archs; do 
    build_cli win $arch wsk.exe windows 
    compress_binaries win $arch wsk.exe zip 
done
