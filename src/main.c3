module lery;
import lery::lexer;
import std::io;
import std::core::dstring;

macro String[].shift(&self) {
	if(self.len == 0) return "";
	String ret = (*self)[0];
	*self = (*self)[1..];
	return ret;
}

fn String File.slurp(self) {
	DString tmp = dstring::new(mem);
	while(true) {
		char? c = self.read_byte();
		if(catch c) break;
		tmp.append(c);
}
	return tmp.copy_str(mem);
}

fn int main(String[] args) {
	String program = args.shift();
	String file = args.shift();
	String opt = args.shift();
	if(file == "") return 1;
	String src = file::open(file, "r")!!.slurp();
	defer src.free(mem);
	Lexer l = lexer::new(src);
	l.setFile(file);
	TokenList list;
	list.init(mem);
	list.collect(&l)!!;
	if(opt == "lex") {
		foreach(t: list) {
			t.show();
		}
		return 0;
	}
	Parser p = parser::new(list, src);
	Program prog = p.parse()!!;
	if(opt == "ast") {
		io::printn("{");
		foreach(i, n: prog) {
			n.show(p.src);
			if(i < prog.len() - 1) {
				io::printn(",");
			} else {
				io::printn("");
			}
		}
		io::printn("}");
	}
	return 0;
}
