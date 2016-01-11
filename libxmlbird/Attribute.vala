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
 * Representation of one XML attribute.
 */
public class Attribute : GLib.Object {
	XmlString ns;
	XmlString name;
	XmlString content;

	string? element_ns = null;
	string? element_name = null;
	string? element_content = null;
	
	internal Attribute (XmlString ns, XmlString name, XmlString content) {
		this.ns = ns;
		this.name = name;
		this.content = content;
	}

	internal Attribute.element (XmlElement element) {
		element_ns = element.get_namespace ();
		element_name = element.get_name ();
		element_content = element.get_content ();
		
		ns = new XmlString ((!) element_ns, ((!) element_ns).length);
		name = new XmlString ((!) element_name, ((!) element_name).length);
		content = new XmlString ((!) element_content, ((!) element_content).length);
	}

	internal Attribute.empty () {
		this.ns = new XmlString("", 0);
		this.name = new XmlString ("", 0);
		this.content = new XmlString ("", 0);
	}
	
	/** 
	 * @return namespace part for this attribute.
	 */
	public string get_namespace () {
		return ns.to_string ();
	}
	
	/**
	 * @return the name of this attribute. 
	 */
	public string get_name () {
		return name.to_string ();
	}

	/** 
	 * @return the value of this attribute.
	 */
	public string get_content () {
		return content.to_string ();
	}
	
	internal int get_name_length () {
		return name.length;
	}
}

}
