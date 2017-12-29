#!/usr/bin/python3
"""
Copyright (C) 2013 2014 2015 Johan Mattsson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import os
import subprocess
import glob
import platform
import sys
from optparse import OptionParser
from scripts import config
from scripts import version
from scripts.run import run

def getDest (file, dir):
	f = dest + prefix + dir + '/'
	s = file.rfind ('/')
	if s > -1:
		f += file[s + 1:]
	else:
		f += file
	return f

def getDestRoot (file, dir):
	f = dest + dir + '/'
	s = file.rfind ('/')
	if s > -1:
		f += file[s + 1:]
	else:
		f += file
	return f

def install (file, dir, mode):
	f = getDest (file, dir)
	print ("install: " + f)
	run ('install -d ' + dest + prefix + dir)
	run ('install -m ' + str(mode) + ' ' + file + ' ' + dest + prefix + dir + '/')

def install_root (file, dir, mode):
	f = getDestRoot (file, dir)
	print ("install: " + f)
	run ('install -d ' + dest + dir)
	run ('install -m ' + str(mode) + ' ' + file + ' ' + dest + dir + '/')

def link (dir, file, linkname):
	f = getDest (linkname, dir)
	print ("install link: " + f)
	run ('cd ' + dest + prefix + dir + ' && ln -sf ' + file + ' ' + linkname)

parser = OptionParser()
parser.add_option ("-d", "--dest", dest="dest", help="install to this directory", metavar="DEST")

(options, args) = parser.parse_args()

if not options.dest:
	options.dest = ""

prefix = config.PREFIX
dest = options.dest

libdir = config.LIBDIR
if "openbsd" in sys.platform:
	install ('build/bin/libxmlbird.so.' + '${LIBxmlbird_VERSION}', libdir, 755)
elif os.path.isfile ('build/bin/libxmlbird.so.' + version.LIBXMLBIRD_SO_VERSION):
	install ('build/bin/libxmlbird.so.' + version.LIBXMLBIRD_SO_VERSION, libdir, 755)
	link (libdir, 'libxmlbird.so.' + version.LIBXMLBIRD_SO_VERSION, ' libxmlbird.so')
elif os.path.isfile ('build/libxmlbird.so.' + version.LIBXMLBIRD_SO_VERSION):
	install ('build/libxmlbird.so.' + version.LIBXMLBIRD_SO_VERSION, libdir, 755)
	link (libdir, 'libxmlbird.so.' + version.LIBXMLBIRD_SO_VERSION, ' libxmlbird.so')
elif os.path.isfile ('build/bin/libxmlbird-' + version.LIBXMLBIRD_SO_VERSION_MAJOR + '.dylib'):
	install ('build/bin/libxmlbird-' + version.LIBXMLBIRD_SO_VERSION_MAJOR + '.dylib', libdir, 755)
	link (libdir, 'libxmlbird-' + version.LIBXMLBIRD_SO_VERSION_MAJOR + '.dylib', ' libxmlbird.dylib')
else:
   print("Can't find libxmlbird, so-version: " + str(version.LIBXMLBIRD_SO_VERSION))
   exit (1)

install ('build/xmlbird/xmlbird.h', '/include', 644)
install ('build/xmlbird.vapi', '/share/vala/vapi', 644)
install ('build/xmlbird.pc', libdir + '/pkgconfig', 644)
