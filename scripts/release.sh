#!/bin/bash
# Copyright (C) 2012, 2013, 2014 Johan Mattsson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

rep="$(pwd)"

mkdir -p build
cd build
mkdir -p export
cd export 

version=$(cat ../../scripts/version.py | grep "XMLBIRD_VERSION = '" | sed -e "s:XMLBIRD_VERSION = '::" | sed "s:'.*::g")

rm -rf libxmlbird-$version

git clone --depth 1 --no-hardlinks --local $rep

mv xmlbird libxmlbird-$version

rm -rf libxmlbird-$version/.git
rm -rf libxmlbird-$version/.gitignore

tar -cf libxmlbird-$version.tar libxmlbird-$version

xz -z libxmlbird-$version.tar

rm -rf ../libxmlbird-$version.tar.xz

mv libxmlbird-$version.tar.xz ../

# build it to make sure that everything was checked in
cd libxmlbird-$version && \
./configure && \
doit && \
gpg --output ../../libxmlbird-$version.tar.xz.sig --detach-sig ../../libxmlbird-$version.tar.xz && \
cd .. && \
rm -rf ../export/libxmlbird-$version
