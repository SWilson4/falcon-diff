#!/bin/sh

set -eux

ref="Falcon-impl-20211101"
oqs="liboqs"

cleanup() {
    if [ -f ${ref}.zip ]; then rm ${ref}.zip; fi
}

trap cleanup EXIT

if [ ! -d ${ref} ]
then
    wget https://falcon-sign.info/${ref}.zip
    unzip ${ref}.zip
    cp test_falcon.c ${ref}
    cd ${ref}
    make
    ./test_falcon
    cd -
    cp ${ref}/falcon512_ref.out ${ref}/falcon1024_ref.out .
fi

if [ ! -d ${oqs} ]
then
    git clone https://github.com/open-quantum-safe/liboqs.git
    cd ${oqs}
    git checkout sw-full-kat
    mkdir build
    cd build
    cmake -GNinja ..
    ninja
    cd ../..
    ./${oqs}/build/tests/kat_sig Falcon-512 --all > falcon512_oqs.out
    ./${oqs}/build/tests/kat_sig Falcon-1024 --all > falcon1024_oqs.out
fi
