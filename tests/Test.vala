/*
    Copyright (C) 2015 Johan Mattsson

    This library is free software; you can redistribute it and/or modify 
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 3 of the 
    License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful, but 
    WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
    Lesser General Public License for more details.
*/
namespace B {

class Test : GLib.Object {
	XmlParser parser;
	
	public Test (string xml_data) {
		parser = new XmlParser (xml_data);
	}
	
	public void test (string values) {
		string content = get_content ();
		bool pass = content == values;
		
		if (!pass) {
			print (@"$content != $values\n");
			assert (pass);
		}
	}
	
	public string get_content () {
		Tag root;
		StringBuilder content;
		
		content = new StringBuilder ();
		root = parser.get_root_tag ();
		add_tag (content, root);
		
		return content.str.strip ();
	}

	void add_tag (StringBuilder content, Tag tag) {
		content.append (tag.get_name ());
		content.append (" ");
		
		foreach (Attribute a in tag.get_attributes ()) {
			content.append (a.get_name ());
			content.append (" ");
			content.append (a.get_content ());
			content.append (" ");
		}
		
		if (!has_children (tag) && tag.get_content () != "") {
			content.append (tag.get_content ());
			content.append (" ");
		}
		
		foreach (Tag t in tag) {
			add_tag (content, t);
		}
	}
	
	bool has_children (Tag tag) {
		foreach (Tag t in tag) {
			return true;
		}
		
		return false;
	}
}

}
