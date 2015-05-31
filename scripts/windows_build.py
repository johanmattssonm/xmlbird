from run import run

run ("mkdir -p build");

run ("valac --ccode --pkg posix --library libxmlbird --vapi=xmlbird.vapi --directory=./build -H ./build/xmlbird.h libxmlbird/*.vala");

run ("""gcc -fPIC -c \
	$(pkg-config --cflags glib-2.0) \
	$(pkg-config --cflags gobject-2.0) \
	build/libxmlbird/*.c""");

run ("mv *.o build/libxmlbird/");

run ("""gcc -shared \
		build/libxmlbird/*.o \
		$(pkg-config --libs glib-2.0) \
		$(pkg-config --libs gobject-2.0) \
		-o build/libxmlbird.dll""");
		