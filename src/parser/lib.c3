module lery::parser;
import std::io;
import lery::lexer;
import std::collections::list;
import lery::utils;

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

fn anyfault Parser.error(&self, Token tok, String error) {
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

fn Token! Parser.expectToken(&self, TokenType tok, bool reserve = true) {
        Token curr = self.pop()!;
        if(curr.type != tok) {
                self.error(curr, "Unexpected Token");
                return ParserFault.UNEXPECTED_TOKEN?;
        }
        if(reserve && tok == TokenType.IDENTIFIER) curr.checkTypeIdent(self)!;
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
                                self.error(curr, "illegal token in program root");
                                return ParserFault.ILLEGAL_TOKEN?;
                }
                curr = self.pop()!;
        }
        return program;
}

fn Type*! Parser.parseType(&self) {
        return self.parseConstType()!;
}

fn Type*! Parser.parseConstType(&self) {
        if(self.peek()!.type == TokenType.CONST) {
                self.pop()!;
                return ast::newRefType(self.parseRefType()!);
        }
        return self.parseRefType()!;
}

fn Type*! Parser.parseRefType(&self) {
        if(self.peek()!.type == TokenType.REF) {
                self.pop()!;
                return ast::newRefType(self.parseArrayType()!);
        }
        return self.parseArrayType()!;
}

fn Type*! Parser.parseArrayType(&self) {
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

fn Type*! Parser.parsePrioType(&self) {
        if(self.peek()!.type == TokenType.LEFT_PAREN) {
                self.pop()!;
                Type* t = self.parseType()!;
                self.expectToken(TokenType.RIGHT_PAREN)!;
                return t;
        }
        return self.parseBaseType()!;
}

fn Type*! Parser.parseBaseType(&self) {
        if(self.peek()!.type == TokenType.FUNCTION) {
                utils::todo("parse function base type");
        } else {
                Token ident = self.expectToken(TokenType.IDENTIFIER, false)!;
                return ast::newTypeIdent(ident);
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
        ExpressionASTNode* left = self.parsePrefixExpression()!;
        Token curr = self.peek()!;
        while(curr.type == TokenType.STAR ||
              curr.type == TokenType.SLASH) {
                curr = self.pop()!;
                left = ast::newBinopExpr(curr, left, self.parsePrefixExpression()!);
                curr = self.peek()!;
        }
        return left;
}

fn ExpressionASTNode*! Parser.parsePrefixExpression(&self) {
        Token curr = self.peek()!;
        switch(curr.type) {
                case TokenType.LEFT_PAREN:
                        self.pop()!;
                        ExpressionASTNode* ret = self.parseExpression()!;
                        self.expectToken(TokenType.RIGHT_PAREN)!;
                        return ret;
                case TokenType.MINUS:
                        Token op = self.pop()!;
                        return ast::newPrefixExpr(op, self.parseUnitExpression()!);
                default:
                        return self.parseUnitExpression()!;
        }
}

fn ExpressionASTNode*! Parser.parseUnitExpression(&self) {
        Token curr = self.pop()!;
        switch(curr.type) {
                case TokenType.INT_LITERAL:
                        return ast::newIntLitExpr(curr);
                case TokenType.IDENTIFIER:
                        curr.checkTypeIdent(self)!;
                        return ast::newIdentifierExpr(curr);
                case TokenType.TRUE: nextcase;
                case TokenType.FALSE:
                        return ast::newBoolLitExpr(curr);
                default:
                        self.error(curr, "unable to parse unit expression");
                        return ParserFault.BAD_UNIT?;
        }
}

fn ASTNode! Parser.parseGlobalVar(&self) {
        Token curr = self.expectToken(TokenType.IDENTIFIER)!;
        self.expectToken(TokenType.COLON)!;
        Type* type = self.parseType()!;
        ExpressionASTNode* val = null;
        if(self.peek()!.type == TokenType.ASSIGNMENT) {
                self.pop()!;
                val = self.parseExpression()!;
        }
        if(val == null) val = ast::newUnitExpr(self.peek()!.span);
        self.expectToken(TokenType.SEMICOLON)!;
        return ast::newGlobalNode(curr, val, type);
}

fn ASTNode! Parser.parseFunction(&self) {
        Token name = self.expectToken(TokenType.IDENTIFIER)!;
        self.expectToken(TokenType.LEFT_PAREN)!;
        ParamList params = self.parseParams()!;
        self.expectToken(TokenType.RIGHT_PAREN)!;
        self.expectToken(TokenType.RIGHT_ARROW)!;
        Type* retType = self.parseType()!;
        Block block = self.parseBlock()!;
        return ast::newFunctionNode(name, params, retType, block);
}

fn ParamList! Parser.parseParams(&self) {
        ParamList params;
        params.new_init();
        bool coma;
        while(self.peek()!.type != TokenType.RIGHT_PAREN) {
                coma = false;
                Token name = self.expectToken(TokenType.IDENTIFIER)!;
                self.expectToken(TokenType.COLON)!;
                Type* type = self.parseType()!;
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
                        curr.checkTypeIdent(self)!;
                        curr = self.peek(1)!;
                        switch(curr.type) {
                                case TokenType.COLON:
                                        return self.parseVarDecl()!;
                                case TokenType.ASSIGNMENT:
                                        return self.parseVarAssign()!;
                                case TokenType.PLUS_ASSIGN: nextcase;
                                case TokenType.ASSIGN_PLUS:
                                        return self.parseVarAssignMod()!;
                                default:
                                        return self.error(curr, "illegal token in statement")? ?? ParserFault.ILLEGAL_TOKEN?;
                        }
                case TokenType.RETURN:
                        self.pop()!;
                        ExpressionASTNode* val = null;
                        if(self.peek()!.type != TokenType.SEMICOLON) val = self.parseExpression()!;
                        if(val == null) val = ast::newUnitExpr(self.peek()!.span);
                        self.expectToken(TokenType.SEMICOLON)!;
                        return ast::newReturnStatement(val);
                default:
                        return self.error(curr, "illegal token in statement")? ?? ParserFault.ILLEGAL_TOKEN?;
        }
}

fn StatementASTNode! Parser.parseVarDecl(&self) {
        Token name = self.expectToken(TokenType.IDENTIFIER)!;
        self.expectToken(TokenType.COLON)!;
        Type* type = self.parseType()!;
        ExpressionASTNode* val = null;
        if(self.peek()!.type == TokenType.ASSIGNMENT) {
                self.pop()!;
                val = self.parseExpression()!;
        }
        if(val == null) val = ast::newUnitExpr(self.peek()!.span);
        self.expectToken(TokenType.SEMICOLON)!;
        return ast::newVarDeclStatement(name, type, val);
}

fn StatementASTNode! Parser.parseVarAssign(&self) {
        Token name = self.expectToken(TokenType.IDENTIFIER)!;
        self.expectToken(TokenType.ASSIGNMENT)!;
        ExpressionASTNode* val = self.parseExpression()!;
        self.expectToken(TokenType.SEMICOLON)!;
        return ast::newVarAssignStatement(name, val);
}

fn StatementASTNode! Parser.parseVarAssignMod(&self) {
        Token name = self.expectToken(TokenType.IDENTIFIER)!;
        Token op = self.pop()!;
        op.span.end--;
        ExpressionASTNode* left = ast::newIdentifierExpr(name);
        ExpressionASTNode* val;
        switch(op.type) {
                case TokenType.PLUS_ASSIGN:
                        op.type = TokenType.PLUS;
                        val = ast::newBinopExpr(op, left, self.parseExpression()!);
                case TokenType.ASSIGN_PLUS:
                        op.type = TokenType.PLUS;
                        val = ast::newBinopExpr(op, self.parseExpression()!, left);
                default:
                        return self.error(op, "unreachable parse var assign mod")? ?? ParserFault.ILLEGAL_TOKEN?;
        }
        self.expectToken(TokenType.SEMICOLON)!;
        return ast::newVarAssignStatement(name, val);
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
