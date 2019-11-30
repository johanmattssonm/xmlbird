/*
	Copyright (C) 2016 Johan Mattsson

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
 * Representation of tags and content in an XML document.
 */
public class XmlElement : GLib.Object {
	string name = "";
	string xml_namespace = "";
	string content = "";
	bool leaf = true;
	unowned XmlElement? parent = null;
	Elements? children = null;
	Elements? attributes = null;
	
	public XmlElement.empty () {
	}
	
	internal XmlElement (XmlElement? parent, Tag tag) {
		name = tag.get_name ();
		xml_namespace = tag.get_namespace ();
		this.parent = parent;

		children = parse_tags (tag);
		attributes = parse_attributes (tag);

		leaf = children == null;
		
		if (leaf) {
			content = tag.get_content ();
		}
	}

	internal XmlElement.attribute (Attribute attribute) {
		name = attribute.get_name ();
		xml_namespace = attribute.get_namespace ();
		content = attribute.get_content ();
	}
	
	~XmlElement () {
		foreach (XmlElement child in this) {
			child.remove_parent ();
		}
	}
	
	public Attributes get_attributes () {
		if (attributes == null) {
			return new Attributes.for_element (new Elements ());
		}
		
		return new Attributes.for_element ((!) attributes);
	}
	
	internal void remove_parent () {
		parent = null;
	}
	
	internal Elements? parse_tags (Tag tag) {
		Elements elements = new Elements ();
		
		foreach (Tag t in tag) {
			elements.add (new XmlElement (this, t));
		}

		if (elements.size == 0) {
			return null;
		}

		return elements;
	}

	internal Elements? parse_attributes (Tag tag) {
		Attributes tag_attributes = tag.get_attributes ();
		Elements elements = new Elements ();

		foreach (Attribute a in tag_attributes) {
			elements.add (new XmlElement.attribute (a));
		}
		
		if (elements.size == 0) {
			return null;
		}

		return elements;	
	}

	/** Get a reference to the parent element. This method will return 
	 * null if the parent element has been deleted, if the method is called
	 * on the root element or if the method is called on an attribute.
	 */
	public XmlElement? get_parent () {
		if (parent == null) {
			return null;
		}
		
		XmlElement e = (!) parent;
		return e;
	}
	
	public bool is_leaf () {
		return leaf;
	}
	
	public string get_name () {
		return name;
	}

	public string get_namespace () {
		return xml_namespace;
	}

	public string get_content () {
		return content;
	}

	public Iterator iterator () {
		return new Iterator (children);
	}

	public class Iterator : GLib.Object {
		int index = -1;
		Elements? xml_elements;
		
		internal Iterator (Elements? xml_elements) {
			this.xml_elements = xml_elements;
		}

		public bool next () {
			if (xml_elements == null) {
				return false;
			}
			
			Elements e = (!) xml_elements;
			index++;
			
			return index < e.size;
		}

		public new XmlElement get () {
			if (unlikely (xml_elements == null)) {
				XmlParser.warning ("No elements available.");
				return new XmlElement.empty ();
			}
			
			Elements e = (!) xml_elements;
			
			if (unlikely (index >= e.size || index < 0)) {
				XmlParser.warning (@"Element index out of bounds ($index >= $(e.size)).");
				return new XmlElement.empty ();
			}
			
			XmlElement element = e.get_element (index);
			return element;
		}
	}
}

}
