module lery::lexer;
import std::io;
import libc;

struct LexerLoc {
        uint line;
        uint column;
        String file;
}

fn void LexerLoc.inc(&self, bool newLine = false) {
        self.column++;
        if(newLine) {
                self.line++;
                self.column = 0;
        }
}

fn void LexerLoc.setFile(&self, String file) => self.file = file;

struct Lexer {
        String program;
        usz position;
        LexerLoc loc;
}

fn Lexer new(String program) => Lexer { .program = program };

fn char! Lexer.peek(&self, usz distance = 0) {
        if(self.position + distance >= self.program.len) return IteratorResult.NO_MORE_ELEMENT?;
        return self.program[self.position + distance];
}

fn void Lexer.advance(&self, usz distance = 1) {
        if(self.position + distance >= self.program.len) distance = self.program.len - self.position;
        for(usz i = 0; i < distance; i++) self.loc.inc(self.program[self.position + i] == '\n');
        self.position += distance;
}

fn Token Lexer.makeSingleCharToken(&self, TokenType type) {
        defer self.advance();
        return token::new(type, self.loc, span::new(self.position, 1));
}

fn Token Lexer.makeTwoCharToken(&self, TokenType type) {
        defer self.advance(2);
        return token::new(type, self.loc, span::new(self.position, 2));
}

fn Token Lexer.makeThreeCharToken(&self, TokenType type) {
        defer self.advance(3);
        return token::new(type, self.loc, span::new(self.position, 2));
}

fn void Lexer.error(&self, String error) @noreturn {
        usz posStart = self.position;
        usz posEnd   = self.position;
        while(posStart != 0 && self.program[posStart] != '\n') posStart--;
        while(posEnd < self.program.len && self.program[posEnd] != '\n') posEnd++;
        if(self.program[posStart] == '\n') posStart++;
        String line = self.program[posStart..posEnd - 1];
        io::eprintf("\n%s\n", error, line);
        io::eprintf("%*s\n", self.loc.column, "^");
        std::core::builtin::panic("Lexer: %s", error);
}

fn void Lexer.skipSingleLineComment(&self) {
        while(true) {
                char! curr = self.peek();
                if(catch curr) return;
                if(curr == '\n') break;
                self.advance();
        }
}

fn void Lexer.skipMultipleLineComment(&self) {
        while(true) {
                char! curr = self.peek();
                if(catch curr) return;
                if(curr == '}') {
                        char! next = self.peek(1);
                        if(catch next) return;
                        if(next == '/') {
                                self.advance(2);
                                return;
                        }
                }
                self.advance();
        }
}

fn Token Lexer.next(&self) {
        char! curr = self.peek();
        if(catch curr) return token::new(TokenType.END_OF_FILE);
        switch(curr) {
                case '-': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.MINUS);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.MINUS_ASSIGN);
                                case '-': return self.makeTwoCharToken(TokenType.DECREMENT);
                                case '>': return self.makeTwoCharToken(TokenType.RIGHT_ARROW);
                                default: return self.makeSingleCharToken(TokenType.MINUS);
                        }
                }
                case '+': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.PLUS);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.PLUS_ASSIGN);
                                case '+': return self.makeTwoCharToken(TokenType.INCREMENT);
                                default: return self.makeSingleCharToken(TokenType.PLUS);
                        }
                }
                case '*': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.STAR);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.STAR_ASSIGN);
                                case '*': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.EXPONENT);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.EXPONENT_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.EXPONENT);
                                        }
                                }
                                default: return self.makeSingleCharToken(TokenType.STAR);
                        }
                }
                case '/': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.SLASH);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.SLASH_ASSIGN);
                                case '/': {
                                        self.skipSingleLineComment();
                                        return self.next();
                                }
                                case '{': {
                                        self.skipMultipleLineComment();
                                        return self.next();
                                }
                                default: return self.makeSingleCharToken(TokenType.SLASH);
                        }
                }
                case '|': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.OR);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.OR_ASSIGN);
                                case '|': return self.makeTwoCharToken(TokenType.BOOL_OR);
                                case '~': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.NOR);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.NOR_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.NOR);
                                        }
                                }
                                default: return self.makeSingleCharToken(TokenType.OR);
                        }
                }
                case '&': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.AND);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.AND_ASSIGN);
                                case '&': return self.makeTwoCharToken(TokenType.BOOL_AND);
                                case '~': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.NAND);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.NAND_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.NAND);
                                        }
                                }
                                default: return self.makeSingleCharToken(TokenType.AND);
                        }
                }
                case '^': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.XOR);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.XOR_ASSIGN);
                                case '~': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.NXOR);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.NXOR_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.NXOR);
                                        }
                                }
                                default: return self.makeSingleCharToken(TokenType.XOR);
                        }
                }
                case '~': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.NOT);
                        switch(next) {
                                case '~': return self.makeTwoCharToken(TokenType.NOTCREMENT);
                                case '|': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.NOR);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.NOR_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.NOR);
                                        }
                                }
                                case '&': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.NAND);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.NAND_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.NAND);
                                        }
                                }
                                case '^': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.NXOR);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.NXOR_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.NXOR);
                                        }
                                }
                                default: return self.makeSingleCharToken(TokenType.NOT);
                        }
                }
                case '=': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.ASSIGNMENT);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.EQUAL);
                                case '+': return self.makeTwoCharToken(TokenType.ASSIGN_PLUS);
                                case '-': return self.makeTwoCharToken(TokenType.ASSIGN_MINUS);
                                case '*': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.ASSIGN_STAR);
                                        switch(next2) {
                                                case '*': return self.makeThreeCharToken(TokenType.ASSIGN_EXPONENT);
                                                default: return self.makeTwoCharToken(TokenType.ASSIGN_STAR);
                                        }
                                }
                                case '/': return self.makeTwoCharToken(TokenType.ASSIGN_SLASH);
                                case '|': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.ASSIGN_OR);
                                        switch(next2) {
                                                case '~': return self.makeThreeCharToken(TokenType.ASSIGN_NOR);
                                                default: return self.makeTwoCharToken(TokenType.ASSIGN_OR);
                                        }
                                }
                                case '&': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.ASSIGN_AND);
                                        switch(next2) {
                                                case '~': return self.makeThreeCharToken(TokenType.ASSIGN_NAND);
                                                default: return self.makeTwoCharToken(TokenType.ASSIGN_AND);
                                        }
                                }
                                case '^': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.ASSIGN_XOR);
                                        switch(next2) {
                                                case '~': return self.makeThreeCharToken(TokenType.ASSIGN_NXOR);
                                                default: return self.makeTwoCharToken(TokenType.ASSIGN_XOR);
                                        }
                                }
                                case '~': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeSingleCharToken(TokenType.ASSIGNMENT);
                                        switch(next2) {
                                                case '|': return self.makeThreeCharToken(TokenType.ASSIGN_NOR);
                                                case '&': return self.makeThreeCharToken(TokenType.ASSIGN_NAND);
                                                case '^': return self.makeThreeCharToken(TokenType.ASSIGN_NXOR);
                                                default: return self.makeSingleCharToken(TokenType.ASSIGNMENT);
                                        }
                                }
                                case '!': return self.makeTwoCharToken(TokenType.NOT_EQUAL);
                                case '>': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.GREATER_EQUAL);
                                        switch(next2) {
                                                case '>': return self.makeThreeCharToken(TokenType.ASSIGN_SHIFT_RIGHT);
                                                default: return self.makeTwoCharToken(TokenType.GREATER_EQUAL);
                                        }
                                }
                                case '<': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.LESS_EQUAL);
                                        switch(next2) {
                                                case '<': return self.makeThreeCharToken(TokenType.ASSIGN_SHIFT_LEFT);
                                                default: return self.makeTwoCharToken(TokenType.LESS_EQUAL);
                                        }
                                }
                                default: return self.makeSingleCharToken(TokenType.ASSIGNMENT);
                        }
                }
                case '!': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.NOT);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.NOT_EQUAL);
                                default: return self.makeSingleCharToken(TokenType.NOT);
                        }
                }
                case '<': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.LESS_THAN);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.LESS_EQUAL);
                                case '<': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.SHIFT_LEFT);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.SHIFT_LEFT_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.SHIFT_LEFT);
                                        }
                                };
                                default: return self.makeSingleCharToken(TokenType.LESS_THAN);
                        }
                }
                case '>': {
                        char! next = self.peek(1);
                        if(catch next) return self.makeSingleCharToken(TokenType.GREATER_THAN);
                        switch(next) {
                                case '=': return self.makeTwoCharToken(TokenType.GREATER_EQUAL);
                                case '>': {
                                        char! next2 = self.peek(2);
                                        if(catch next2) return self.makeTwoCharToken(TokenType.SHIFT_RIGHT);
                                        switch(next2) {
                                                case '=': return self.makeThreeCharToken(TokenType.SHIFT_RIGHT_ASSIGN);
                                                default: return self.makeTwoCharToken(TokenType.SHIFT_RIGHT);
                                        }
                                }
                                default: return self.makeSingleCharToken(TokenType.GREATER_THAN);
                        }
                }
                case ',': return self.makeSingleCharToken(TokenType.COMMA);
                case '(': return self.makeSingleCharToken(TokenType.LEFT_PAREN);
                case ')': return self.makeSingleCharToken(TokenType.RIGHT_PAREN);
                case '{': return self.makeSingleCharToken(TokenType.LEFT_BRACKET);
                case '}': return self.makeSingleCharToken(TokenType.RIGHT_BRACKET);
                case '[': return self.makeSingleCharToken(TokenType.LEFT_BRACE);
                case ']': return self.makeSingleCharToken(TokenType.RIGHT_BRACE);
                case ':': return self.makeSingleCharToken(TokenType.COLON);
                case ';': return self.makeSingleCharToken(TokenType.SEMICOLON);
                default: self.error("Unexpected character");
        }
}
