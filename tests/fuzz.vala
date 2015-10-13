using B;

int main (string[] args) {
	if (args.length != 2) {
		stderr.printf (@"Usage: $(args[0]) FILE_NAME");
		return 1;
	}
	
	string filename = args[1];
	string xml;
	FileUtils.get_contents (filename, out xml);
	
	B.Test test = new B.Test (xml);
	test.get_content ();
	
	return 0;
}
