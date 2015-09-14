#!/usr/bin/python

import os

from config import PREFIX
from run import run
from version import LIBXMLBIRD_SO_VERSION
from pkgconfig import generate_pkg_config_file

run ("mkdir -p build/bin");

run ("valac --ccode --pkg posix --library libxmlbird --vapi=xmlbird.vapi "
     + "--directory=./build -H ./build/xmlbird.h libxmlbird/*.vala");

run ("""gcc -fPIC -c \
     $(pkg-config --cflags glib-2.0) \
     $(pkg-config --cflags gobject-2.0) \
     build/libxmlbird/*.c""");

run ("mv *.o build/libxmlbird/");

run ("""gcc -shared \
     -Wl,-soname,""" + "libxmlbird.so." + LIBXMLBIRD_SO_VERSION + "\
     build/libxmlbird/*.o \
     $(pkg-config --libs glib-2.0) \
     $(pkg-config --libs gobject-2.0) \
     -o build/bin/libxmlbird.so.""" + LIBXMLBIRD_SO_VERSION);

if os.path.islink('build/bin/libxmlbird.so'):
    run("unlink build/bin/libxmlbird.so")
    
run ("cd build/bin/ && \
     ln -s libxmlbird.so.""" + LIBXMLBIRD_SO_VERSION + " libxmlbird.so");
	
generate_pkg_config_file()
