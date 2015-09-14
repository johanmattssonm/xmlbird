#!/usr/bin/python

from config import PREFIX
from run import run
from version import LIBXMLBIRD_SO_VERSION

tests = []
f = open("tests/all_tests.txt")
line = f.readline().strip ()
while line:
    if not line == "":
        tests += [line]
    line = f.readline().strip ()

run ("mkdir -p build/bin");

for test in tests:
    run("valac --includedir=build --vapidir=build --pkg=xmlbird tests/Test.vala tests/" + test + ".vala -o build/" + test)
