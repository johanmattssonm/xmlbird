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

/**
 * Representation of one XML tag.
 */
public class Tag : GLib.Object {
	internal XmlData entire_file;
	
	int tag_index; 
	int attribute_index;
	
	bool has_tags;
	bool has_attributes;
	
	XmlString name;
	XmlString data;
	XmlString attributes;
	
	Tag? next_tag = null;
	Attribute? next_attribute = null;
	
	internal bool error {
		get {
			return parser_error;
		}
		
		set {
			Tag t = this;
			t.parser_error = value;	
			
			while (t.parent != null) {
				t = (!) t.parent;
				t.parser_error = value;	
			}
		}
	}
	bool parser_error = false;
	
	internal int log_level = WARNINGS;

	bool parsed = false;
	
	Tag? parent = null;

	internal Tag (XmlString name, XmlString attributes, XmlString content,
		int log_level, XmlData entire_file, Tag? parent = null) {
		
		this.entire_file = entire_file;
		this.log_level = log_level;
		this.name = name;
		this.data = content;
		this.attributes = attributes;
		this.parent = parent;
	}
	
	internal Tag.empty () {
		entire_file = new XmlData ("", 0, NONE);
		data = new XmlString ("", 0);
		attributes = new XmlString ("", 0);
		name = new XmlString ("", 0);
		error = true;
	}
	
	/** 
	 * Get tag attributes for this tag. 
	 * @return a container with all the attributes
	 */
	public Attributes get_attributes () {
		return new Attributes (this);
	}

	/** 
	 * Iterate over all tags inside of this tag.
	 */
	public Iterator iterator () {
		return new Iterator(this);
	}

	/** 
	 * Reset the parser and start from the beginning XML tag.
	 */
	public void reparse () {
		tag_index = 0;
		next_tag = obtain_next_tag ();
		parsed = true;
	}

	internal void reparse_attributes () {
		attribute_index = 0;
		next_attribute = obtain_next_attribute ();
	}
	
	/** 
	 * Obtain the name of the tag.
	 * @return the name of this tag. 
	 */ 
	public string get_name () {
		return name.to_string ();
	}

	/** 
	 * Obtain tag content.
	 * @return data between the start and end tags.
	 */
	public string get_content () {
		return data.to_string ();
	}

	/** 
	 * @return true if there is one more tags left
	 */
	internal bool has_more_tags () {
		if (!parsed) {
			reparse ();
			reparse_attributes ();
		}

		return has_tags && !error;
	}
	
	/** @return the next tag. **/
	internal Tag get_next_tag () {
		if (!parsed) {
			reparse ();
			reparse_attributes ();
		}
		
		Tag r = next_tag == null ? new Tag.empty () : (!) next_tag;
		next_tag = obtain_next_tag ();
		return r;
	}

	/** @return true is there is one or more attributes to obtain with get_next_attribute */
	internal bool has_more_attributes () {
		if (!parsed) {
			reparse ();
			reparse_attributes ();
		}
		
		return has_attributes && !error;
	}
	
	/** @return next attribute. */
	internal Attribute get_next_attribute () {
		if (!parsed) {
			reparse ();
			reparse_attributes ();
		}
		
		Attribute r = next_attribute == null ? new Attribute.empty () : (!) next_attribute;
		next_attribute = obtain_next_attribute ();
		return r;
	}
	
	internal bool has_failed () {
		return error;
	}
	
	Tag obtain_next_tag () {
		int end_tag_index;
		Tag tag;
		
		if (error) {
			has_tags = false;
			return new Tag.empty ();
		}
		
		tag = find_next_tag (tag_index, out end_tag_index);

		if (end_tag_index != -1 && error == false) {
			tag_index = end_tag_index;
			has_tags = true;
			return tag;
		}
		
		has_tags = false;
		return new Tag.empty ();
	}
	
	Tag find_next_tag (int start, out int end_tag_index) {
		int index;
		unichar c;
		int separator;
		int end;
		int closing_tag;
		XmlString? d;

		XmlString name;
		XmlString attributes;
		XmlString content;
		
		string tag_name;
	
		end_tag_index = -1;
		
		if (error) {
			return new Tag.empty ();
		}
	
		if (unlikely (start < 0)) {
			warn ("Negative index.");
			error = true;
			return new Tag.empty ();
		}
	
		index = start;

		d = data;
		if (unlikely (d == null)) {
			warn ("No data in xml string.");
			error = true;
			return new Tag.empty ();
		}
			
		while (data.get_next_ascii_char (ref index, out c)) {
			if (c == '<') {
				separator = data.find_next_tag_separator (index);

				if (unlikely (separator < 0)) {
					error = true;
					warn ("Expecting a separator.");
					return new Tag.empty ();
				}

				name = data.substring (index, separator - index);
				tag_name = name.to_string ();
				
				if (unlikely (tag_name == "")) {
					warn ("A tag without a name.");
					error = true;
					return new Tag.empty ();
				}
				
				if (name.has_prefix ("!")) {
					continue;
				}

				if (unlikely (name.has_prefix ("/"))) {
					warn ("Expecting a new tag. Found a closing tag.");
					error = true;
					return new Tag.empty ();
				}
								
				// skip attributes
				end = find_end_of_tag (separator); 
								
				if (unlikely (end == -1)) {
					error = true;
					warn ("Expecting >.");
					return new Tag.empty ();
				}
				
				attributes = data.substring (separator, end - separator);
				
				if (attributes.has_suffix ("/")) {
					content = new XmlString ("", 0);
					end_tag_index = find_end_of_tag (index);
					data.get_next_ascii_char (ref end_tag_index, out c);
				} else {
					if (unlikely (!data.get_next_ascii_char (ref end, out c))) {; // skip >
						warn ("Unexpected end of data.");
						error = true;
						break;
					}
					
					if (unlikely (c != '>')) {
						warn (@"Expecting '>' found $((!) c.to_string ())");
						error = true;
						break;
					}
					
					closing_tag = find_closing_tag (name, end);
					
					if (unlikely (closing_tag == -1 || closing_tag >= data.length)) {
						warn (@"No closing tag for $name");
						error = true;
						break;
					}
					
					content = data.substring (end, closing_tag - end);
					end_tag_index = find_end_of_tag (closing_tag);
									
					if (unlikely (end_tag_index == -1)) {
						error = true;
						warn ("Expecting > for the closing tag.");
						return new Tag.empty ();
					}
					
					data.get_next_ascii_char (ref end_tag_index, out c);
				}
					
				return new Tag (name, attributes, content, log_level, entire_file, this);	
			}
		}
	
		return new Tag.empty ();
	}
	
	int find_end_of_tag (int start) {
		int index;
		int current;
		unichar c;

		index = start;
		current = start;
		while (data.get_next_ascii_char (ref index, out c)) {
			if (c == '>') {
				return current;
			}
			
			if (c == '"') {
				index = find_end_quote (index);
				
				if (index == -1) {					
					break;
				}
				
				data.get_next_ascii_char (ref index, out c);
			}
			
			current = index;
		}
		
		error = true;
		warn ("Tag not closed.");
		
		return -1;
	}
	
	int find_end_quote (int start) {
		int i = data.index_of ("\"", start);
		
		if (unlikely (i == -1)) {
			warn ("Expecting end quote.");
			error = true;
		}
		
		return i;
	}
	
	int find_closing_tag (XmlString name, int start) {
		int index = start;
		int slash_index = start;
		int previous_index;
		unichar c, slash;
		int start_count = 1;
		int tag_start;
		string tag_name;
		
		if (unlikely (name.length == 0)) {
			error = true;
			warn ("No name for tag.");
			error = true;
			return -1;
		}
	
		index = entire_file.get_index (data) + start;
		
		if (unlikely (index >= entire_file.length)) {
			warn ("Unexpected end of file");
			error = true;
			return -1;
		}

		while (true) {
			while (!entire_file.substring (index).has_prefix ("<")) {
				index = entire_file.find_next_tag_token (index + 1);
				
				if (index == -1) {
					warn (@"No end tag for $(name).");
					error = true;
					return -1;
				}
			}

			previous_index = index - entire_file.get_index (data);
			
			if (unlikely (!entire_file.get_next_ascii_char (ref index, out c))) {
				warn ("Unexpected end of file");
				error = true;
				break;
			}
			
			if (c == '<') {
				tag_start = index;
				slash_index = index;
				entire_file.get_next_ascii_char (ref slash_index, out slash);
				
				tag_name = parse_name (entire_file, tag_start);
				
				if (unlikely (tag_name == "")) {
					warn (@"Tag without name.");
					warn (@"Row: $(get_row (tag_start))");
					error = true;
					return -1;
				}
				
				if (slash == '/' && is_tag (entire_file, name, slash_index)) {
					if (start_count == 1) {
						return previous_index;
					} else {
						start_count--;
						if (start_count == 0) {
							return previous_index;
						}
					}
				} else if (is_tag (entire_file, name, tag_start)) {
					start_count++;
				} 
			}
		}
		
		error = true;
		warn (@"No closing tag for $(name.to_string ())");
		
		return -1;
	}
	
	string parse_name (XmlData data, int index) {
		int slash_offset = 0;
		
		if (data.substring (index).has_prefix("/")) {
			slash_offset = "/".length;
			index += slash_offset;
		}
		
		int separator = data.find_next_tag_separator (index);

		if (unlikely (!(0 <= separator < data.length))) {
			warn("Tag without name.");
			return "";
		}

		return data.substring (index - slash_offset, separator - index + slash_offset).to_string ();
	}
	
	bool is_tag (XmlString tag, XmlString name, int start) {
		int index = 0;
		int data_index = start;
		unichar c;
		unichar c_data;
		
		while (name.get_next_ascii_char (ref index, out c)) {
			if (tag.get_next_ascii_char (ref data_index, out c_data)) {
				if (c_data != c) {
					return false;
				}
			}
		}
		
		if (tag.get_next_ascii_char (ref data_index, out c_data)) {
			return c_data == '>' || c_data == ' ' || c_data == '\t' 
				|| c_data == '\n' || c_data == '\r' || c_data == '/';
		}
		
		return false;
	}

	internal Attribute obtain_next_attribute () {
		int previous_index;
		int index = attribute_index;
		int name_start;
		XmlString attribute_name;		
		XmlString ns;
		XmlString content;
		int ns_separator;
		int content_start;
		int content_stop;
		unichar quote;
		unichar c;
	
		if (error) {
			return new Attribute.empty ();
		}
							
		// skip space and other separators
		while (true) {
			previous_index = index;
			
			if (!attributes.get_next_ascii_char (ref index, out c)) {
				has_attributes = false;
				return new Attribute.empty ();
			}
			
			if (!(c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '/')) {
				break;
			}
		}
		
		name_start = previous_index;

		// read attribute name
		while (true) {
			previous_index = index;
			if (!attributes.get_next_ascii_char (ref index, out c)) {
				error = true;
				warn (@"Unexpected end of attributes in tag $(this.name)");
				has_attributes = false;
				return new Attribute.empty ();
			}
			
			if (c == ' ' || c == '\t' || c == '=' || c == '\n' || c == '\r') {
				break;
			}
		}
		
		attribute_name = attributes.substring (name_start, previous_index - name_start);
		index = name_start + attribute_name.length;
		ns = new XmlString ("", 0);
		ns_separator = attribute_name.index_of (":");
		if (ns_separator != -1) {
			ns = attribute_name.substring (0, ns_separator);
			attribute_name = attribute_name.substring (ns_separator + 1);
		}
		
		// equal sign and space around it
		while (attributes.get_next_ascii_char (ref index, out c)) {
			if (!(c == ' ' || c == '\t' || c == '\n' || c == '\r')) {
				if (likely (c == '=')) {
					break;
				} else {
					has_attributes = false;
					error = true;
					warn (@"Expecting equal sign for attribute $(attribute_name).");
					warn (@"Row: $(get_row (((size_t) attributes.data) + index))");
					
					return new Attribute.empty ();
				}
			}
		}
		
		while (attributes.get_next_ascii_char (ref index, out c)) {
			if (!(c == ' ' || c == '\t' || c == '\n' || c == '\r')) {
				if (likely (c == '"' || c == '\'')) {
					break;
				} else {
					has_attributes = false;
					error = true;
					warn (@"Expecting quote for attribute $(attribute_name).");
					return new Attribute.empty ();
				}
			}
		}
		
		quote = c;
		content_start = index;
		
		while (true) {
			if (unlikely (!attributes.get_next_ascii_char (ref index, out c))) {
				has_attributes = false;
				error = true;
				warn (@"Expecting end quote for attribute $(attribute_name).");
				return new Attribute.empty ();
			}
			
			if (c == quote) {
				break;
			}
		}
		
		content_stop = index - 1;
		content = attributes.substring (content_start, content_stop - content_start);
		
		has_attributes = true;
		
		attribute_index = content_stop + 1;
		return new Attribute (ns, attribute_name, content);
	}

	public class Iterator : GLib.Object {
		Tag tag;
		Tag? next_tag = null;
		
		internal Iterator (Tag t) {
			tag = t;
			tag.reparse ();
		}

		public bool next () {
			if (tag.has_more_tags ()) {
				next_tag = tag.get_next_tag ();
			} else {
				next_tag = null;
			}

			if (unlikely (next_tag != null && ((!) next_tag).error)) {
				next_tag = null;
				tag.error = true;
			}
															
			return next_tag != null;
		}

		public new Tag get () {
			if (unlikely (next_tag == null)) {
				XmlParser.warning ("No tag is parsed yet.");
				return new Tag.empty ();
			}
			return (!) next_tag;
		}
	}
	
	internal int get_row (size_t pos) {
		int index = 0;
		unichar c;
		int row = 1;
		size_t e;
		
		e = (size_t) entire_file.data;
		while (entire_file.get_next_ascii_char (ref index, out c)) {
			if (c == '\n') {
				row++;
			}
			
			if (e + index >= pos) {
				break;
			}
		}
		
		return row;
	}
	
	internal void warn (string message) {
		if (log_level == WARNINGS) {
			XmlParser.warning (message);
		}
	}
}

}
