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

internal class XmlData : XmlString {
	int* start_tags;
	int tags_capacity;
	int tags_size;
	
	internal bool error = false;
	
	const char FIRST_BIT = 1 << 7;

	internal int log_level = WARNINGS;
	
	public XmlData (char* data, int length, int log_level) {
		base (data, length);

		this.log_level = log_level;
		
		start_tags = null;
		tags_capacity = 0;
		tags_size = 0;
		
		index_start_tags ();
	}
	
	~XmlData () {
		if (start_tags != null) {
			delete start_tags;
			start_tags =  null;
		}
	}
	
	public int get_index (XmlString start) {
		int offset = (int) ((size_t) start.data - (size_t) data);
		return offset;
	}
		
	public int find_next_tag_token (int index) {
		int new_index;
				
		if (index >= length) {
			return -1;
		}
		
		for (int i = 0; i < tags_size; i++) {
			new_index = start_tags[i];
			if (new_index >= index) {
				return new_index;
			}
		}
		
		return -1;
	}

	void index_start_tags () {
		int i = 0;
		char* d = data;
 		char c;
 		bool tag_is_open = false;
 		
 		c = d[i];
 		
 		while (c != '\0') {
			if ((int) (c & FIRST_BIT) == 0) {
				
				if (tag_is_open && c == '"') {
					i = skip_quote (d, i);
					
					if (unlikely (i == -1)) {
						if (log_level == WARNINGS) {
							XmlParser.warning ("No end quote.");
						}
						
						error = true;
						break;
					}
				}
				
				if (c == '<') {
					add_tag (i);
					tag_is_open = true;
				}
				
				if (c == '>') {
					tag_is_open = false;
				}
			}
			
			i++;
			c = d[i];
		}
	}
	
	int skip_quote (char* data, int i) {
 		char c;
 		
 		c = data[i];
 		
		if (unlikely (c != '"')) {
			if (log_level == WARNINGS) {
				XmlParser.warning ("Not a quote.");
			}

			error = true;
			return i + 1;
		}
		
 		while (c != '\0') {
			if ((int) (c & FIRST_BIT) == 0) {
				if (c == '"') {
					return i + 1;
				}
			}
			
			i++;
			c = data[i];
		}
		
		return -1;
	}
	
	void add_tag (int index) {
		if (unlikely (tags_size == tags_capacity)) {
			if (!increase_capacity ()) {
				return;
			}
		}
		
		start_tags[tags_size] = index;
		tags_size++;
	}

	bool increase_capacity () {
		int* tags;
		
		tags_capacity += 512;
		tags = (int*) try_malloc (tags_capacity * sizeof (int));
		
		if (unlikely (tags == null)) {
			tags_capacity = 0;
			
			if (start_tags != null) {
				delete start_tags;
				start_tags = null;
				tags_size = 0;
				error = true;
			}

			if (log_level == WARNINGS) {
				XmlParser.warning ("Can not allocate xml data buffer.");
			}
			
			return false;
		}
		
		if (tags_size > 0) {
			Posix.memcpy (tags, start_tags, tags_size * sizeof (int));
		}
		
		if (start_tags != null) {
			delete start_tags;
		}
		
		start_tags = tags;
		
		return true;
	}
}

}
