#!/usr/bin/python
import subprocess
from config import PREFIX
from run import run
from version import LIBXMLBIRD_SO_VERSION

def read_elements(file):
    tests = []
    f = open(file)
    line = f.readline().strip ()
    while line:
        if not line == "":
            tests += [line]
        line = f.readline().strip ()
        
    return tests

def get_benchmarks():
    return read_elements("tests/benchmarks.txt")

def get_tests():
    return read_elements("tests/tests.txt")

def all_tests():
    tests = get_benchmarks()
    tests += get_tests()
    return tests

def build_tests():
    tests = all_tests() + ["fuzz"]
    run ("mkdir -p build/bin");
    run ("mkdir -p build/tests");

    for test in tests:
        run ("valac --ccode --pkg posix --pkg=xmlbird --vapidir=./build "
             + "--directory=./build tests/" + test + ".vala tests/Test.vala");

        run ("""gcc -fPIC -c \
             $(pkg-config --cflags glib-2.0) \
             $(pkg-config --cflags gobject-2.0) \
             -I ./build -L./build/bin -lxmlbird \
             build/tests/""" + test + """.c \
             build/tests/Test.c""");

        run ("mv *.o build/tests/");

        run ("""gcc build/tests/""" + test + """.o build/tests/Test.o \
             $(pkg-config --libs glib-2.0) \
             $(pkg-config --libs gobject-2.0) \
             -L./build/bin -lxmlbird \
             -o ./build/bin/""" + test);

