/*
    Copyright (C) 2014 Johan Mattsson

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

/** Log levels */
internal const int NONE = 0;
internal const int WARNINGS = 1;

/** 
 * XML parser
 * 
 * XML parser written in Vala.
 * 
 * Example:
 * {{{
 * 
 * using B;
 * 
 * // Print all tags and attributes in an XML document. 
 * // Expected output:
 * // tag1
 * // tag2
 * // attribute1
 * public static int main (string[] arg) {
 * 	Tag root;
 * 	XmlParser parser;
 * 
 * 	parser = new XmlParser ("""<tag1><tag2 attribute1=""/></tag1>""");	
 * 
 * 	if (!parser.validate ()) {
 * 		warning ("Invalid XML.");
 * 		return 1;
 * 	}
 * 
 * 	root = parser.get_root_tag ();
 * 	print_tags (root);
 * 
 * 	return 0;
 * }
 * 
 * 
 * void print_tags (Tag tag) {
 * 	print (tag.get_name ());
 * 	print ("\n");
 * 	print_attributes (tag);
 * 
 * 	foreach (Tag t in tag) {
 * 		print_tags (t);
 * 	}
 * }
 * 
 * void print_attributes (Tag tag) {
 * 	Attributes attributes = tag.get_attributes ();
 * 	foreach (Attribute attribute in attributes) {
 * 		print (attribute.get_name ());
 * 		print ("\n");
 * 	}
 * }
 * 
 * }}}
 * 
 */
public class XmlParser : GLib.Object {
	Tag root;
	XmlData data;
	string input;
	bool error;
	
	/** 
	 * Create a new xml parser. 
	 * @param data valid xml data
	 */
	public XmlParser (string data) {
		this.input = data;
		this.data = new XmlData (data, data.length, NONE);		
		reparse (NONE);
	}
		
	/** 
	 * Determine if the document can be parsed.
	 * @return true if the xml document is valid xml.
	 */
	public bool validate () {
		bool valid;
		
		if (this.data.error) {
			error = true;
			return false;
		} 
		
		reparse (NONE);

		if (error) {
			return false;
		}
		
		valid = validate_tags (root);
			
		reparse (NONE);
		return valid;
	}
	
	bool validate_tags (Tag tag) {
		Attributes attributes = tag.get_attributes ();
		
		tag.log_level = NONE;
		
		foreach (Attribute a in attributes) {
			if (error || tag.has_failed () || a.get_name_length () == 0) {
				return false;
			}
		}
		
		foreach (Tag t in tag) {
			if (error || t.has_failed () || tag.has_failed ()) {
				return false;
			}
			
			if (!validate_tags (t)) {
				return false;
			}
		}

		if (tag.has_failed ()) {
			return false;
		}
				
		return true;		
	}
	
	/** 
	 * Obtain the root tag.
	 * @return the root tag. 
	 */
	public Tag get_root_tag () {
		reparse (WARNINGS);
		return root;
	}
	
	/** 
	 * Reset the parser and start from the beginning of the XML document. 
	 */
	internal void reparse (int log_level) {
		int root_index;
		Tag container;
		XmlString content;
		XmlString empty;
		
		error = false;
		empty = new XmlString ("", 0);
		
		data.log_level = log_level;
		
		root_index = find_root_tag ();
		if (root_index == -1) {
			if (log_level == WARNINGS) {
				XmlParser.warning ("No root tag found.");
			}
			error = true;
			root = new Tag.empty ();
		} else {
			content = data.substring (root_index);
			container = new Tag (empty, empty, content, log_level, data);
			root = container.get_next_tag ();
			
			if (container.has_failed ()) {
				error = true;
			}
		}
	}
	
	int find_root_tag () {
		int index = 0;
		int prev_index = 0;
		int modifier = 0;
		unichar c;
		
		while (true) {
			prev_index = index;
			if (!data.get_next_ascii_char (ref index, out c)) {
				break;
			}
			
			if (c == '<') {
				modifier = index;
				data.get_next_ascii_char (ref modifier, out c);
				if (c != '?' && c != '[' && c != '!') {
					return prev_index;
				} 
			}
		}
		
		return -1;
	}

	/**
	 * Print a warning message.
	 */
	internal static void warning (string message) {
		print ("XML error: "); 
		print (message);
		print ("\n");
	}

	/**
	 * Replace escaped character with plain text characters. 
	 * &amp; will be replaced with & etc.
	 */
	public static string decode (string s) {
		string t;
		t = s.replace ("&quot;", "\"");
		t = t.replace ("&apos;", "'");
		t = t.replace ("&lt;", "<");
		t = t.replace ("&gt;", ">");
		t = t.replace ("&amp;", "&");
		return t;
	}

	/**
	 * Replace ", ' < > and & with encoded characters.
	 */
	public static string encode (string s) {
		string t;
		t = s.replace ("&", "&amp;");
		t = t.replace ("\"", "&quot;");
		t = t.replace ("'", "&apos;");
		t = t.replace ("<", "&lt;");
		t = t.replace (">", "&gt;");	
		return t;
	}

}

}
