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

rm -rf xmlbird-$version

git clone --depth 1 --no-hardlinks --local $rep

mv xmlbird xmlbird-$version

rm -rf xmlbird-$version/.git
rm -rf xmlbird-$version/.gitignore

tar -cf xmlbird-$version.tar xmlbird-$version

xz -z xmlbird-$version.tar

rm -rf ../xmlbird-$version.tar.xz

mv xmlbird-$version.tar.xz ../

# build it to make sure that everything was checked in
cd xmlbird-$version && \
./configure && \
doit && \
gpg --output ../../xmlbird-$version.tar.xz.sig --detach-sig ../../xmlbird-$version.tar.xz && \
cd .. && \
rm -rf ../export/xmlbird-$version
