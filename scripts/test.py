#!/usr/bin/python
import subprocess

tests = []
f = open("tests/all_tests.txt")
line = f.readline().strip ()
while line:
    if not line == "":
        tests += [line]
    line = f.readline().strip ()

for test in tests:
    process = subprocess.Popen ("./build/" + test, shell=True)
    process.communicate()[0]
    
    if not process.returncode == 0:
        print(test + ' Failed')
        exit (1)
    else:
        print(test + ' Passed')
    
