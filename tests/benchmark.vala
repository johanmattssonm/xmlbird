
string get_string (int length) {
	StringBuilder s = new StringBuilder ();
	
	while (length-- > 0) {
		s.append ("a");
	}
	
	return s.str;
}

string generate_big_xml_file () {
	string name;
	StringBuilder xml = new StringBuilder ();
	
	for (int i = 0; i < 10000; i++) {
		name = get_string (20);
		xml.append ("<tag_with_long_name ");
		xml.append ("attribute");
		xml.append ("=\"");
		xml.append (get_string (i));
		xml.append ("\">");
		xml.append ("<data>");
		xml.append (get_string (i));
		xml.append ("</data>");
		xml.append ("</tag_with_long_name>");
	}
	
	return xml.str;
}


public static int main (string[] arg) {
	B.Test t;
	
	t = new B.Test (generate_big_xml_file ());
	t.benchmark ("Big file");
	
	return 0;
}

