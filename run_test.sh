#!/bin/sh

ls ./build/bin
if [ -e $1 ]; then
	PKG_PATH=./build/bin $1
	exit $?
fi

echo "No test provided. ($1)"
exit 1

