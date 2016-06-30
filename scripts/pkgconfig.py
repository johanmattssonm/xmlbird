from scripts import config
from scripts import version

def generate_pkg_config_file():
        f = open('./build/xmlbird.pc', 'w+')
        f.write("prefix=" + config.PREFIX + "\n")
        f.write("""exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: xmlbird
Description: XML parser
Version: """ + version.XMLBIRD_VERSION + """
Cflags: -I${includedir}
Libs: -L${libdir} -lxmlbird
Requires: glib-2.0
""")
