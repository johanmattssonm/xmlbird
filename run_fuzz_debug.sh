#!/bin/sh

PKG_PATH=$(dirname "$(readlink -f "$0")")
cd "${PKG_PATH}"
LD_LIBRARY_PATH=./build/bin:$LD_LIBRARY_PATH gdb ./build/bin/fuzz

