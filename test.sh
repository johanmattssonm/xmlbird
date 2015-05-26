#!/bin/sh
export LD_LIBRARY_PATH="./build/:./build/bin:$LD_LIBRARY_PATH"
PKG_PATH=$(dirname "$(readlink -f "$0")")
cd "${PKG_PATH}"

valac --pkg=xmlbird tests/Test.vala tests/minimal.vala -o build/test && \
	echo "Run test" && \
	./build/test && \
	echo "Passed"

