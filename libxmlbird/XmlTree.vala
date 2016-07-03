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
 * A representation of a XML tree.
 * 
 * All XML elements are owned by the tree and will be deleted when the 
 * tree is deleted.
 */
public class XmlTree : GLib.Object {
	
	XmlElement root_element = new XmlElement.empty ();
	bool valid = true;
	
	public XmlTree (string xml) {
		XmlParser parser = new XmlParser (xml);

		if (!parser.validate ()) {
			valid = false;
			XmlParser.warning ("Invalid XML.");
			return;
		}
		
		root_element = new XmlElement (null, parser.get_root_tag ());
	}

	public XmlTree.for_tag (Tag root) {
		this.root_element = new XmlElement (null, root);
	}
	
	public XmlElement get_root () {
		return root_element;
	}
	
	public bool validate () {
		return valid;
	}
}

}
