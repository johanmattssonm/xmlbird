from config import PREFIX
from run import run
from version import LIBXMLBIRD_SO_VERSION
from pkgconfig import generate_pkg_config_file
run ("mkdir -p build/bin");

run ("valac --ccode --pkg posix --library libxmlbird --vapi=xmlbird.vapi --directory=./build -H ./build/xmlbird.h libxmlbird/*.vala");

run ("""gcc -fPIC -c \
	$(pkg-config --cflags glib-2.0) \
	$(pkg-config --cflags gobject-2.0) \
	build/libxmlbird/*.c""");

run ("mv *.o build/libxmlbird/");

run ("""gcc -shared \
		-Wl,-install_name,"""  + PREFIX + """/lib/libxmlbird-""" + LIBXMLBIRD_SO_VERSION + """.dylib \
		build/libxmlbird/*.o \
		$(pkg-config --libs glib-2.0) \
		$(pkg-config --libs gobject-2.0) \
		-o build/bin/libxmlbird-""" + LIBXMLBIRD_SO_VERSION + ".dylib");
		
generate_pkg_config_file()