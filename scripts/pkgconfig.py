from scripts import config

def generate_pkg_config_file():
        f = open('./build/xmlbird.pc', 'w+')
        f.write("prefix=" + config.PREFIX + "\n")
        f.write("""exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: xmlbird
Description: XML parser
Version: 1.0.0
Cflags: -I${includedir}
Libs: -L${libdir} -lxmlbird
""")
