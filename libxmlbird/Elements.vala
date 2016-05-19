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

internal class Elements : GLib.Object {
	private XmlElement** data;
	public int size = 0;
	int capacity = 10;
	
	public Elements () {
		data = new XmlElement*[capacity];
	}

	~Elements () {
		for (int i = 0; i < size; i++) {
			XmlElement e = data[i];
			e.unref ();
		}
		delete data;
		data = null;
	}
	
	public XmlElement get_element (int index) {
		if (unlikely (index < 0 || index >= size)) {
			XmlParser.warning ("Index out of bounds in Elements.");
			return new XmlElement.empty ();
		}
		
		return data[index];
	}
	
	public void add (XmlElement element) {
		if (size >= capacity) {
			int new_capacity = 2 * capacity;
			XmlElement** new_data = new XmlElement*[new_capacity];
			Posix.memcpy (new_data, data, sizeof (double) * size);
			delete data;
			data = new_data;
			capacity = new_capacity;
		}
		
		data[size] = element;
		element.ref ();
		size++;
	}

}

}
