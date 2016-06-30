![xmlbird logo][xmlbird]

# XML Bird - XML parser

XML Bird is an XML parser for programs written in Vala or C.

    Author: Johan Mattsson
    License: LGPL v3
    Webpage: https://birdfont.org/xmlbird.php

[![Build Status](https://travis-ci.org/johanmattssonm/xmlbird.svg?branch=master)]
(https://travis-ci.org/johanmattssonm/xmlbird)

## Building from Source

Install valac and Glib first.

Configure, build and install with doit:

    ./configure
    doit
    sudo ./install.py

The default prefix is /usr/local on some systems should XML Bird be 
compiled with /usr as prefix.

    ./configure --prefix=/usr

Exampel usage:

    using B;

    // Print all tags and attributes in an XML document. 
    // Expected output:
    // tag1
    // tag2
    // attribute1
    public static int main (string[] arg) {
        Tag root;
        XmlParser parser;

        parser = new XmlParser ("""<tag1><tag2 attribute1=""/></tag1>""");	

        if (!parser.validate ()) {
            warning ("Invalid XML.");
            return 1;
        }

        root = parser.get_root_tag ();
        print_tags (root);

        return 0;
    }


    void print_tags (Tag tag) {
        print (tag.get_name ());
        print ("\n");
        print_attributes (tag);

        foreach (Tag t in tag) {
            print_tags (t);
        }
    }

    void print_attributes (Tag tag) {
        Attributes attributes = tag.get_attributes ();
        foreach (Attribute attribute in attributes) {
            print (attribute.get_name ());
            print ("\n");
        }
    }

## Hacking

There is a test suite with benchmarks. Run “doit test”.

XML Bird is a part of the [Birdfont][birdfont] project.

[xmlbird]: https://birdfont.org/images/xmlbird-icon.png "XML Bird icon"
[birdfont]: https://birdfont.org/ "Birdfont – Font Editor"


