module lery::parser;
import std::io;
import lery::lexer;
import std::collections::list;

def TokenList = list::List(<Token>);

fn void! TokenList.collect(&self, Lexer *l) {
        Token t = l.next()!;
        while(t.type != TokenType.END_OF_FILE) {
                self.push(t);
                t = l.next()!;
        }
        self.push(t);
}

fault ParserFault {
        EMPTY_PROGRAM,
        ILLEGAL_TOKEN,
        UNEXPECTED_TOKEN,
        BAD_UNIT,
}

struct Parser {
        TokenList tokens;
        String src;
}

fn Parser new(TokenList tokens, String src) => Parser { .tokens = tokens, .src = src };

fn anyfault Parser.error(&self, Token tok, String error) @noreturn {
        usz posStart = tok.span.start;
        usz posEnd   = tok.span.end;
        while(posStart != 0 && self.src[posStart] != '\n') posStart--;
        while(posEnd < self.src.len && self.src[posEnd] != '\n') posEnd++;
        if(self.src[posStart] == '\n') posStart++;
        String line = self.src[posStart..posEnd - 1];
        io::eprintf("[ERROR] %s:%d:%d => %s\n%s\n", tok.loc.file, tok.loc.line, tok.loc.column, error, line);
        io::eprintf("%*s\n", tok.loc.column, "^");
        return LexerFault.ERROR;
}

fn Token! Parser.peek(self, usz distance = 0) {
        Token! curr = self.tokens[distance];
        if(catch curr) return self.error(token::new(TokenType.END_OF_FILE), "got no end of file at en file end")? ?? ParserFault.EMPTY_PROGRAM?;
        return curr;
}

fn Token! Parser.pop(&self) {
        Token curr = self.peek()!;
        self.tokens.pop_first()!!;
        return curr;
}

fn Token! Parser.expectToken(&self, TokenType tok) {
        Token curr = self.pop()!;
        if(curr.type != tok) return self.error(curr, "Unexpected Token")? ?? ParserFault.UNEXPECTED_TOKEN?;
        return curr;
}

fn Program! Parser.parse(Parser *self) {
        Program program;
        program.new_init();
        Token curr = self.pop()!;
        while (curr.type != TokenType.END_OF_FILE) {
                switch(curr.type) {
                        case TokenType.GLOBAL:
                                program.push(self.parseGlobalVar()!);
                        case TokenType.FUNCTION:
                                program.push(self.parseFunction()!);
                        default:
                                return self.error(curr, "illegal token in program root")? ?? ParserFault.ILLEGAL_TOKEN?;
                }
                curr = self.pop()!;
        }
        return program;
}

fn Type! Parser.parseType(&self) {
        usz dim;
        bool isRef;
        bool isConst;
        if(self.peek()!.type == TokenType.REF) {
                self.pop()!;
                isRef = true;
        }
        if(self.peek()!.type == TokenType.CONST) {
                self.pop()!;
                isConst = true;
        }
        if(self.peek()!.type == TokenType.FUNCTION) {
                unreachable("todo");
        } else {
                Token ident = self.expectToken(TokenType.IDENTIFIER)!;
                while(self.peek()!.type == TokenType.LEFT_BRACE) {
                        self.pop()!;
                        dim++;
                        self.expectToken(TokenType.RIGHT_BRACE)!;
                }
                return ast::newTypeIdent(ident, dim, isRef, isConst);
        }
}

fn ExpressionASTNode*! Parser.parseExpression(&self) {
        return self.parseLV1Expression()!;
}

fn ExpressionASTNode*! Parser.parseLV1Expression(&self) {
        ExpressionASTNode* left = self.parseLV2Expression()!;
        Token curr = self.peek()!;
        while(curr.type == TokenType.PLUS ||
              curr.type == TokenType.MINUS) {
                curr = self.pop()!;
                left = ast::newBinopExpr(curr, left, self.parseLV2Expression()!);
                curr = self.peek()!;
        }
        return left;
}

fn ExpressionASTNode*! Parser.parseLV2Expression(&self) {
        ExpressionASTNode* left = self.parseUnitExpression()!;
        Token curr = self.peek()!;
        while(curr.type == TokenType.STAR ||
              curr.type == TokenType.SLASH) {
                curr = self.pop()!;
                left = ast::newBinopExpr(curr, left, self.parseUnitExpression()!);
                curr = self.peek()!;
        }
        return left;
}

fn ExpressionASTNode*! Parser.parseUnitExpression(&self) {
        Token curr = self.pop()!;
        switch(curr.type) {
                case TokenType.INT_LITERAL:
                        return ast::newIntLitExpr(curr);
                default:
                        return self.error(curr, "unable to parse unit expression")? ?? ParserFault.BAD_UNIT?;
        }
}

fn ASTNode! Parser.parseGlobalVar(&self) {
        Token curr = self.expectToken(TokenType.IDENTIFIER)!;
        self.expectToken(TokenType.COLON)!;
        Type type = self.parseType()!;
        ExpressionASTNode* val = null;
        if(self.peek()!.type == TokenType.ASSIGNMENT) {
                self.pop()!;
                val = self.parseExpression()!;
        }
        self.expectToken(TokenType.SEMICOLON)!;
        return ast::newGlobalNode(curr, val, type);
}

fn ASTNode! Parser.parseFunction(&self) {
        Token name = self.expectToken(TokenType.IDENTIFIER)!;
        self.expectToken(TokenType.LEFT_PAREN)!;
        ParamList params = self.parseParams()!;
        self.expectToken(TokenType.RIGHT_PAREN)!;
        self.expectToken(TokenType.RIGHT_ARROW)!;
        Type retType = self.parseType()!;
        Block block = self.parseBlock()!;
        return newFunctionNode(name, params, retType, body);
}

fn ParamList! Parser.parseParams(&self) {
        ParamList params;
        params.new_init();
        bool coma;
        while(self.peek()!.type != TokenType.RIGHT_PAREN) {
                coma = false;
                Token name = self.expectToken(TokenType.IDENTIFIER)!;
                self.expectToken(TokenType.COLON)!;
                Type type = self.parseType()!;
                params.push(ast::newFunctionParam(name, type));
                if(self.peek()!.type == TokenType.COMMA) {
                        coma = true;
                        self.pop()!;
                        continue;
                }
        }
        if(coma) self.expectToken(TokenType.COMMA)!;
        return params;
}

fn StatementASTNode! Parser.parseStatement(&self) {
        Token curr = self.peek()!;
        switch(curr.type) {
                case TokenType.IDENTIFIER:
                        unreachable("TODO: var assign, var decl, label, function call");
                default:
                        return self.error(curr, "illegal token in function statement")? ?? ParserFault.ILLEGAL_TOKEN?;
        }
}

fn Block! Parser.parseBlock(&self) {
        Block block;
        block.new_init();
        self.expectToken(TokenType.LEFT_BRACKET)!;
        while(self.peek()!.type != TokenType.RIGHT_BRACKET) {
                block.push(self.parseStatement()!);
        }
        self.expectToken(TokenType.RIGHT_BRACKET)!;
        return block;
}
