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
 * Iterator for XML attributes. 
 */
public class Attributes : GLib.Object {
	
	Tag? tag = null;
	Elements? elements = null;
	
	internal Attributes (Tag t) {
		tag = t;
	}

	internal Attributes.for_element (Elements elements) {
		this.elements = elements;
	}
		
	public Iterator iterator () {
		if (tag != null) {
			return new Iterator (tag);
		}
		
		return new Iterator.for_elements (elements);
	}

	public class Iterator : GLib.Object {
		Tag? tag = null;
		Attribute? next_attribute = null;
		Elements elements = null;
		int index = 0;
		
		internal Iterator (Tag t) {
			tag = t;
			tag.reparse_attributes ();
		}

		internal Iterator.for_elements (Elements elements) {
			this.elements = elements;
		}

		public bool next () {
			if (tag != null) {
				return next_tag ((!) tag);
			}
			
			if (elements != null) {
				return next_element ((!) elements);
			}
			
			return false;
		}

		internal bool next_tag (Tag tag) {
			if (tag.has_more_attributes ()) {
				next_attribute = tag.get_next_attribute ();
			} else {
				next_attribute = null;
			}
			
			return next_attribute != null;			
		}

		internal bool next_element (Elements elements) {
			if (index < elements.size) {
				XmlElement e = elements.get_element (index);
				next_attribute = new Attribute.element (e);
				index++;
			} else {
				next_attribute = null;
			}
			
			return next_attribute != null;			
		}
		
		public new Attribute get () {
			if (next_attribute == null) {
				XmlParser.warning ("No attribute available.");
				return new Attribute.empty ();
			}
			
			return (!) next_attribute;
		}
	}
}

}
