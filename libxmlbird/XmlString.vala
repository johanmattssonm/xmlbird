/*
    Copyright (C) 2014 2015 Johan Mattsson

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
 * Representation of a string in the XmlParser. This class adds reference 
 * counting and copies a pointer to the string instead of the data. It is 
 * faster if the string is big.
 */
internal class XmlString : GLib.Object {	
	public int length;
	public char* data;
	
	internal XmlString (char* data, int length) {
		this.data = data;
		this.length = length;
	}
	
	internal XmlString.empty () {
		this.data = "";
		this.length = 0;
	}
	
	internal int find_next_tag_separator (int start) {
		int index = start;
		int previous_index = start;
		unichar c;
		
		while (true) {
			previous_index = index;
			if (!get_next_ascii_char (ref index, out c)) {
				break;
			}
			
			if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '>' || c == '/') {
				return previous_index;
			}
		}
		
		return -1;
	}
	
	internal int index_of (string needle, int offset = 0) {
		int len = length;
		int needle_len = needle.length;
		char* needle_data = (char*) needle;
		char* haystack = data + offset;
		
		if (needle_len == 0 || offset > length) {
			return -1;
		}
		
		for (int i = 0; i < len; i++) {
			if (haystack[i] == '\0') {
				return -1;
			}
			
			for (int j = 0; j <= needle_len && i + j < len; j++) {
				if (j == needle_len) {
					return offset + i;
				}
				
				if (needle_data[j] != haystack[i + j]) {
					break;
				}
			}
		}
								
		return -1;
	}

	internal bool has_prefix (string prefix) {
		unowned string s = (string) data;
		bool p = s.has_prefix (prefix);

		if (!p) {
			return false;
		}
		
		return length > prefix.length;
	}

	internal bool has_suffix (string suffix) {
		int suffix_length = suffix.length;

		if (length < suffix_length) {
			return false;
		}
		
		return Posix.strncmp ((string) (data + length - suffix_length), suffix, suffix_length) == 0;
	}	

	internal bool get_next_char (ref int index, out unichar c) {
		unowned string s;
		unowned string? n = (string) data;
		
		if (index >= length) {
			c = '\0';
 			return false;
 		}
 		
		s = (!) n;
 		
		return s.get_next_char (ref index, out c);
 	}
 	
	internal bool get_next_ascii_char (ref int index, out unichar c) {
		const char first_bit = 1 << 7;
		int i = index;
		char* d = data;

		if (index >= length) {
			c = '\0';
 			return false;
 		}
 		
		if ((int) (d[i] & first_bit) == 0) {
			c = d[i];
			index++;
			return c != '\0';
		}
		
		while ((int) (d[i] & first_bit) != 0) {
			i++;
		}
		
		index = i;
		return get_next_char (ref index, out c);
	}

	internal XmlString substring (int offset, int len = -1) {
		Posix.assert (offset >= 0);
		Posix.assert (offset < length);
		
		if (len == -1) {
			return new XmlString (data + offset, length - offset);
		}

		Posix.assert (len + offset < length); 
		return new XmlString (data + offset, len);
	} 
	
	public string to_string () {
		unowned string s = (string) data;
		
		if (length == 0) {
			return "".dup ();
		}		
		
		return s.ndup (length);
	}
}

}
