#!/bin/sh

PKG_PATH=$(dirname "$(readlink -f "$0")")
cd "${PKG_PATH}"

if [ -e $1 ]; then
	LD_LIBRARY_PATH=./build/bin:$LD_LIBRARY_PATH ./build/bin/fuzz $1
	exit $?
fi

echo "Can not find file ($1)"
exit 1

