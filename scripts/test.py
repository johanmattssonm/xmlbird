#!/usr/bin/python
import subprocess

from tests import get_tests

tests = get_tests();

for test in tests:
    process = subprocess.Popen("./build/bin/" + test, shell=True)
    process.communicate()[0]
    
    if not process.returncode == 0:
        print(test + ' Failed')
        exit (1)
    else:
        print(test + ' Passed')
    
