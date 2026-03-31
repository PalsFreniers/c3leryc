module lery::parser;
import lery::lexer;
import lery::utils;

fn Type*? Parser.parseType(&self) {
        return self.parseConstType()!;
}

fn Type*? Parser.parseConstType(&self) {
        if(self.peek()!.type == TokenType.CONST) {
                self.pop()!;
                return ast::newRefType(self.parseRefType()!);
        }
        return self.parseRefType()!;
}

fn Type*? Parser.parseRefType(&self) {
        if(self.peek()!.type == TokenType.REF) {
                self.pop()!;
                return ast::newRefType(self.parseArrayType()!);
        }
        return self.parseArrayType()!;
}

fn Type*? Parser.parseArrayType(&self) {
        Type* base = self.parsePrioType()!;
        usz dim;
        while(self.peek()!.type == TokenType.LEFT_BRACE) {
                self.pop()!;
                dim++;
                self.expectToken(TokenType.RIGHT_BRACE)!;
        }
        if(dim != 0) return ast::newArrayType(base, dim);
        return base;
}

fn Type*? Parser.parsePrioType(&self) {
        if(self.peek()!.type == TokenType.LEFT_PAREN) {
                self.pop()!;
                Type* t = self.parseType()!;
                self.expectToken(TokenType.RIGHT_PAREN)!;
                return t;
        }
        return self.parseBaseType()!;
}

fn Type*? Parser.parseBaseType(&self) {
        if(self.peek()!.type == TokenType.FUNCTION) {
                utils::todo("parse function base type");
        } else {
                Token ident = self.expectToken(TokenType.IDENTIFIER, false)!;
                return ast::newTypeIdent(ident);
        }
}
