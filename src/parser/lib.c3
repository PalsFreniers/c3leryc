module lery::parser;
import std::io;
import lery::lexer;
import std::collections::list;
import lery::utils;

alias TokenList = list::List{ Token };

fn void? TokenList.collect(&self, Lexer *l) {
	Token t = l.next()!;
	while(t.type != TokenType.END_OF_FILE) {
		self.push(t);
		t = l.next()!;
	}
	self.push(t);
}

faultdef ERROR,
EMPTY_PROGRAM,
ILLEGAL_TOKEN,
UNEXPECTED_TOKEN,
BAD_UNIT;

struct Parser {
	TokenList tokens;
	String src;
}

fn Parser new(TokenList tokens, String src) => (Parser) { 
	tokens = tokens,
	src = src
};

fn fault Parser.error(&self, Token tok, String error) {
	usz posStart  = tok.span.start;
	usz posEnd    = tok.span.end;
	usz len       = posEnd - posStart;
	usz spanStart = posStart;
	while(posStart != 0 && self.src[posStart] != '\n') posStart--;
	while(posEnd < self.src.len && self.src[posEnd] != '\n') posEnd++;
	if(self.src[posStart] == '\n') posStart++;
	if(posEnd - spanStart < len) len = posEnd - spanStart;
	String line = self.src[posStart..posEnd - 1];
	io::printf("[ERROR] %s:%d:%d => %s\n%s\n", tok.loc.file, tok.loc.line, tok.loc.column, error, line);
	io::printf("%*s", tok.loc.column, "^");
	if(len > 1) for(int i = 0; i < len - 1; i++) io::print("~");
	io::printn("");
	return ERROR;
}

fn Token? Parser.peek(self, usz distance = 0) {
	Token? curr = self.tokens[distance];
	if(catch curr) {
		self.error(token::new(TokenType.END_OF_FILE), "got no end of file at en file end");
		return EMPTY_PROGRAM~;
	}
	return curr;
}

fn Token? Parser.pop(&self) {
	Token curr = self.peek()!;
	self.tokens.pop_first()!!;
	return curr;
}

fn Token? Parser.expectToken(&self, TokenType tok, bool reserve = true) {
	Token curr = self.pop()!;
	if(curr.type != tok) {
		self.error(curr, "Unexpected Token");
		return UNEXPECTED_TOKEN~;
	}
	if(reserve && tok == TokenType.IDENTIFIER) curr.checkTypeIdent(self)!;
	return curr;
}

fn Program? Parser.parse(Parser *self) {
	Program program;
	program.init(mem);
	Token curr = self.pop()!;
	while (curr.type != TokenType.END_OF_FILE) {
		switch(curr.type) {
		case TokenType.GLOBAL:
			program.push(self.parseGlobalVar()!);
		case TokenType.FUNCTION:
			program.push(self.parseFunction()!);
		default:
			self.error(curr, "illegal token in program root");
			return ILLEGAL_TOKEN~;
		}
		curr = self.pop()!;
	}
	return program;
}
