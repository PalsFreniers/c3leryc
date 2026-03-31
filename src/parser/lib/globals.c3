module lery::parser;
import lery::lexer;
import lery::utils;

fn ASTNode? Parser.parseGlobalVar(&self) {
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

fn ASTNode? Parser.parseFunction(&self) {
	Token name = self.expectToken(TokenType.IDENTIFIER)!;
	self.expectToken(TokenType.LEFT_PAREN)!;
	ParamList params = self.parseParams()!;
	self.expectToken(TokenType.RIGHT_PAREN)!;
	self.expectToken(TokenType.RIGHT_ARROW)!;
	Type* retType = self.parseType()!;
	Block block = self.parseBlock()!;
	return ast::newFunctionNode(name, params, retType, block);
}

fn ParamList? Parser.parseParams(&self) {
	ParamList params;
	params.init(mem);
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

