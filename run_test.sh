#!/bin/sh
PKG_PATH=$(dirname "$(readlink -f "$1")")

echo $PKG_PATH
if [ -e $1 ]; then
	$1
	exit $?
fi

echo "No test provided. ($1)"
exit 1

