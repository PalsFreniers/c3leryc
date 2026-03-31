module lery::parser;
import lery::lexer;
import lery::utils;

fn ExpressionASTNode*? Parser.parseExpression(&self) {
	return self.parseLV1Expression()!;
}

fn ExpressionASTNode*? Parser.parseLV1Expression(&self) {
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

fn ExpressionASTNode*? Parser.parseLV2Expression(&self) {
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

fn ExpressionASTNode*? Parser.parsePrefixExpression(&self) {
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

fn ExpressionASTNode*? Parser.parseUnitExpression(&self) {
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
		return BAD_UNIT~;
	}
}

