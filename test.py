#!/usr/bin/python
import subprocess
from scripts import tests

tests = tests.get_tests();

for test in tests:
    print('Running tests:')
    process = subprocess.Popen("./run_test.sh ./build/bin/" + test, shell=True)
    process.communicate()[0]
    
    if not process.returncode == 0:
        print(test + ' failed')
        exit (1)
    else:
        print(test + ' passed')
    
