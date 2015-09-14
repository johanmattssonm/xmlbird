"""
Copyright (C) 2012 2013 2014 2015 Eduardo Naufel Schettino and Johan Mattsson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
"""

import os
import glob
import subprocess
import sys

from optparse import OptionParser
from doit.tools import run_once
from doit.action import CmdAction
from scripts.bavala import Vala
from scripts import version
from scripts import config
from scripts.run import run
from scripts.pkgconfig import generate_pkg_config_file
from scripts.tests import all_tests
from scripts.tests import build_tests

DOIT_CONFIG = {
    'default_tasks': [
        'libxmlbird',
        'pkgconfig'
        ],
    }

LIBXMLBIRD_LIBS = [
    'glib-2.0'
]

valac_options = [
	'--enable-experimental-non-null',
	'--enable-experimental'
	]

tests = all_tests ();

if "kfreebsd" in sys.platform:
    LIBXMLBIRD_SO_VERSION=version.LIBXMLBIRD_SO_VERSION
elif "bsd" in sys.platform:
    LIBXMLBIRD_SO_VERSION='${LIBxmlbird_VERSION}'
else:
    LIBXMLBIRD_SO_VERSION=version.LIBXMLBIRD_SO_VERSION
    
libxmlbird = Vala(src='libxmlbird', build='build', library='xmlbird', so_version=LIBXMLBIRD_SO_VERSION, pkg_libs=LIBXMLBIRD_LIBS)
def task_libxmlbird():
    yield libxmlbird.gen_c(valac_options + ['--pkg posix'])
    yield libxmlbird.gen_o(['-fPIC'])
    yield libxmlbird.gen_so()
    yield libxmlbird.gen_ln()

def task_distclean ():
    return  {
        'actions': ['rm -rf .doit.db build scripts/config.py scripts/*.pyc dodo.pyc'],
        }

def task_pkgconfig():
    """generate a pkg-config file"""
    return {
	     'actions': [generate_pkg_config_file]
    }

def task_pkg_flags():
    """get compiler flags for libs/pkgs """
    for pkg in LIBXMLBIRD_LIBS:
        cmd = 'pkg-config --cflags --libs {pkg}'

        yield {
            'name': pkg,
            'actions': [CmdAction(cmd.format(pkg=pkg), save_out='out')],
            'uptodate': [run_once],
            }

def task_build_tests():
    """build tests"""
    return {
	     'actions': [build_tests],
	     'task_dep': ['libxmlbird'],
    }
    
def task_test():
    """run tests"""
    
    def run_tests():
        print('Running tests')
        failed = 0
        passed = 0
        for t in tests:
            process = subprocess.Popen ("./build/bin/" + t, shell=True)
            process.communicate()[0]
            if not process.returncode == 0:
					 print(t + ' Failed')
					 failed = failed + 1
            else:
			       passed = passed + 1
			       
        print(str(passed) + ' tests passed and ' + str(failed) + ' failed.')
		   
    return {
	     'actions': [run_tests],
	     'task_dep': ['build_tests'],
	     'verbosity': 2
    }
