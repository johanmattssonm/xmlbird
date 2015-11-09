#!/usr/bin/python3
	
import subprocess
from os import path

def fuzz():
    process = subprocess.Popen ("mkdir -p build/tests", shell=True)
    process.communicate()[0]
    if not process.returncode == 0:
        print('Can not create test directory.')
        exit(1)

    fuzzed_file = 'build/tests/fuzzy.xml'
    process = subprocess.Popen ("radamsa tests/test.xml > " + fuzzed_file, shell=True)
    process.communicate()[0]
    if not process.returncode == 0:
        print('Can not create a fuzzed file. Radamsa is required.')
        exit(1)

    process = subprocess.Popen ('./run_fuzz.sh ' + fuzzed_file, shell=True)
    process.communicate()[0]
    if not process.returncode == 0:
        print("A bug was found.")
        
        i = 0
        bug_file = ''
        while path.isfile (bug_file) or bug_file == '':
            i = i + 1
            bug_file = 'build/fuzzy_bug_' + str(i) + '.xml'

        process = subprocess.Popen ('mv build/tests/fuzzy.xml ' + bug_file, shell=True)
        process.communicate()[0]
        if not process.returncode == 0:
            print('Can not move ' + bug_file)
            exit(1)
        else:
            print('Saving bug in ' + bug_file)

i = 0
while True:
    print('Running fuzz tests ' + str(i))
    fuzz ()

        	
    i = i + 1
