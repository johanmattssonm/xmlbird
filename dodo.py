import os
import glob
import subprocess
import sys

from scripts import version
from scripts import config
from scripts import tests
from scripts import pkgconfig
from scripts.builder import Builder

DOIT_CONFIG = {
    'default_tasks': [
        'libxmlbird',
        'libxmlbird_pkgconfig'
        ],
    }

all_tests = tests.all_tests ();

def soname(target_binary):
    if "darwin" in sys.platform or "win32" in sys.platform:
        return ''
        
    return '-Wl,-soname,' + target_binary
    
def make_libxmlbird(target_binary):
    valac_command = config.VALAC + """\
        -C \
        --pkg posix \
        --vapidir=./ \
        --basedir build/libxmlbird/ \
        """ + config.NON_NULL + """ \
        """ + config.VALACFLAGS.get("xmlbird", "") + """ \
        --enable-experimental \
        --library libxmlbird \
        --vapi=./build/xmlbird.vapi \
        -H build/xmlbird/xmlbird.h \
        libxmlbird/*.vala \
        """

    cc_command = config.CC + " " + config.CFLAGS.get("xmlbird", "") + """ \
            -c C_SOURCE \
            -I ./build/xmlbird \
            -fPIC \
            $(pkg-config --cflags glib-2.0) \
            -o OBJECT_FILE"""

    linker_command = config.CC + " " + config.LDFLAGS.get("xmlbird", "") + """ \
            -shared \
            """ + soname(target_binary) + """ \
            build/libxmlbird/*.o \
            $(pkg-config --libs glib-2.0) \
            $(pkg-config --libs gobject-2.0) \
            -o ./build/bin/""" + target_binary

    libxmlbird = Builder('libxmlbird',
                          valac_command, 
                          cc_command,
                          linker_command,
                          target_binary,
                          'libxmlbird.so')
			
    yield libxmlbird.build()

def task_libxmlbird():
    if "kfreebsd" in sys.platform:
        LIBXMLBIRD_SO_VERSION=version.LIBXMLBIRD_SO_VERSION
    elif "openbsd" in sys.platform:
        LIBXMLBIRD_SO_VERSION='${LIBxmlbird_VERSION}'
    else:
        LIBXMLBIRD_SO_VERSION=version.LIBXMLBIRD_SO_VERSION
    
    yield make_libxmlbird('libxmlbird.so.' + LIBXMLBIRD_SO_VERSION)

def make_libxmlbird_pkgconfig():
    pkgconfig.generate_pkg_config_file ()

def task_libxmlbird_pkgconfig():
    """build tests"""
    return {
	     'actions': [make_libxmlbird_pkgconfig],
	     'task_dep': ['libxmlbird'],
    }
    
def task_distclean ():
    return  {
        'actions': ['rm -rf .doit.db build scripts/config.py scripts/*.pyc *.pyc'],
        }

def task_build_tests():
    """build tests"""
    return {
	     'actions': [tests.build_tests],
	     'task_dep': ['libxmlbird'],
    }
    
def task_fuzz():
    """run fuzz test"""
    return {
	     'actions': ['./tests/fuzz.py'],
	     'task_dep': ['build_tests'],
    }
        
def task_test():
    """run tests"""
    
    def run_tests():
        print('Running tests')
        failed = 0
        passed = 0
        for t in all_tests:
            process = subprocess.Popen ("./run_test.sh ./build/bin/" + t, shell=True)
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
