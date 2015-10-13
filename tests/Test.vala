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
	string data;
	
	public Test (string xml_data) {
		this.data = xml_data;
	}
	
	public bool validate () {
		parser = new XmlParser (data);
		return parser.validate ();
	}
	
	public void test (string values) {
		string content = get_content ();
		bool pass = content == values;
		
		if (!pass) {
			print (@"$content != $values\n");
			assert (pass);
		}
	}
	
	public void benchmark (string task_name) {
		double start_time, stop_time, t;
		
		start_time = GLib.get_real_time ();
		get_content ();
		stop_time = GLib.get_real_time ();
		
		t = (stop_time - start_time) / 1000000.0;
		
		print (task_name + @" took $t seconds.\n");
	}
	
	public string get_content () {
		Tag root;
		StringBuilder content;
		
		parser = new XmlParser (data);
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
