#!/usr/bin/python3

def write_compile_parameters (prefix, dest, cc, valac, non_null,
                              valacflags, cflags, ldflags):
    f = open('./scripts/config.py', 'w+')
    f.write("#!/usr/bin/python3\n")
    f.write("PREFIX =  \"" + prefix + "\"\n")
    f.write("DEST = \"" + dest + "\"\n")
    f.write("CC = \"" + cc + "\"\n")
    f.write("VALAC = \"" + valac + "\"\n")

    if non_null:
        f.write("NON_NULL = \"--enable-experimental-non-null\"\n")
    else:
        f.write("NON_NULL = \"\"\n")
        
    f.write("VALACFLAGS = " + str(valacflags) + "\n")
    f.write("CFLAGS = " + str(cflags) + "\n")
    f.write("LDFLAGS = " + str(ldflags) + "\n")
