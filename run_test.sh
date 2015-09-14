#!/bin/sh
PKG_PATH=./build/bin

if [ -e $1 ]; then
	$1
	exit $?
fi

echo "No test provided. ($1)"
exit 1

