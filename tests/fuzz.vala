namespace B {

int main (string[] args) {
	if (args.length != 2) {
		stderr.printf (@"Usage: $(args[0]) FILE_NAME");
		return 1;
	}
	
	string filename = args[1];
	string xml;
	FileUtils.get_contents (filename, out xml);
	
	Test test = new Test (xml);
	
	if (test.validate ()) {
		test.get_content ();
	}
	
	return 0;
}

}
