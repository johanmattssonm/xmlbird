namespace B {

int main (string[] args) {
	if (args.length < 2) {
		stderr.printf (@"Usage: $(args[0]) FILE_NAME");
		return 1;
	}
	
	for (int i = 1; i < args.length; i++) {
		string filename = args[i];
		string xml;
		
		if (args.length > 2) {
			stdout.printf ("%s\n", filename);
		}
		
		FileUtils.get_contents (filename, out xml);
		
		Test test = new Test (xml);
		
		if (test.validate ()) {
			test.get_content ();
		}
	}
	
	return 0;
}

}
