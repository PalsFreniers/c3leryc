module lery::parser;
import lery::lexer;
import lery::utils;

fn StatementASTNode? Parser.parseStatement(&self) {
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
			self.error(curr, "illegal token in statement");
			return ILLEGAL_TOKEN~;
		}
	case TokenType.RETURN:
		self.pop()!;
		ExpressionASTNode* val = null;
		if(self.peek()!.type != TokenType.SEMICOLON) val = self.parseExpression()!;
		if(val == null) val = ast::newUnitExpr(self.peek()!.span);
		self.expectToken(TokenType.SEMICOLON)!;
		return ast::newReturnStatement(val);
	default:
		self.error(curr, "illegal token in statement");
		return ILLEGAL_TOKEN~;
	}
}

fn StatementASTNode? Parser.parseVarDecl(&self) {
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

fn StatementASTNode? Parser.parseVarAssign(&self) {
	Token name = self.expectToken(TokenType.IDENTIFIER)!;
	self.expectToken(TokenType.ASSIGNMENT)!;
	ExpressionASTNode* val = self.parseExpression()!;
	self.expectToken(TokenType.SEMICOLON)!;
	return ast::newVarAssignStatement(name, val);
}

macro Parser.makeBinopAssign(&self, $isleft, op, token, other) {
	token.type = op;
	$if $isleft:
		return ast::newBinopExpr(token, self.parseExpression()!, other);
	$else
		return ast::newBinopExpr(token, other, self.parseExpression()!);
	$endif
}

macro Parser.makePreBinopAssign(&self, op, token, other) => self.makeBinopAssign(false, op, token, other);
macro Parser.makePostBinopAssign(&self, op, token, other) => self.makeBinopAssign(true, op, token, other);

fn StatementASTNode? Parser.parseVarAssignMod(&self) {
	Token name = self.expectToken(TokenType.IDENTIFIER)!;
	Token op = self.pop()!;
	op.span.end--;
	ExpressionASTNode* left = ast::newIdentifierExpr(name);
	ExpressionASTNode* val;
	switch(op.type) {
	case TokenType.PLUS_ASSIGN: self.makePreBinopAssign(TokenType.PLUS, op, left)!;
	case TokenType.ASSIGN_PLUS: self.makePostBinopAssign(TokenType.PLUS, op, left)!;
	default:
		self.error(op, "unreachable parse var assign mod");
		return ILLEGAL_TOKEN~;
	}
	self.expectToken(TokenType.SEMICOLON)!;
	return ast::newVarAssignStatement(name, val);
}

fn Block? Parser.parseBlock(&self) {
	Block block;
	block.init(mem);
	self.expectToken(TokenType.LEFT_BRACKET)!;
	while(self.peek()!.type != TokenType.RIGHT_BRACKET) {
		block.push(self.parseStatement()!);
	}
	self.expectToken(TokenType.RIGHT_BRACKET)!;
	return block;
}
