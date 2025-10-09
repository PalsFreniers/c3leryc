module lery::parser::ast;
import lery::lexer;
import std::collections::list;
import std::io;

enum ASTKind {
		GLOBAL_DECL,
		FUNCTION_DECL,
}

union ASTData {
		GlobalDeclASTNode globalDecl;
		FunctionDeclASTNode functionDecl;
}

struct ASTNode {
		ASTKind kind;
		ASTData as;
}

fn void ASTNode.show(self, String src) {
		switch(self.kind) {
				case ASTKind.GLOBAL_DECL:
						io::printf("\"global decl `%s`\": {\n\"type\": ", self.as.globalDecl.name.as.ident);
						self.as.globalDecl.type.show();
						io::printf(",\n\"value\": ");
						self.as.globalDecl.value.show(src);
						io::print("}");
				case ASTKind.FUNCTION_DECL:
						io::printfn("\"function decl `%s`\": {", self.as.functionDecl.name.as.ident);
						io::print("\"params\": [");
						foreach(i, p: self.as.functionDecl.params) {
								io::printf("{\n\"name\": \"%s\",\n\"type\": ", p.name.as.ident);
								p.type.show();
								io::print("}");
								if(i < self.as.functionDecl.params.len() - 1) {
										io::printn(",");
								} else {
										io::printn("");
								}
						}
						io::printn("],");
						io::print("\"return type\": ");
						self.as.functionDecl.returnType.show();
						io::printn(",");
						self.as.functionDecl.body.show(src);
						io::print("\n}");
		}
}

macro newASTNode(kind, data) => ASTNode {
		kind = kind,
		as = data,
};

alias Program = list::List{ ASTNode };
alias Block   = list::List{ StatementASTNode };

fn void Block.show(self, String src) {
		io::print("\"block\": [");
		foreach(i, s: self) {
				s.show(src);
				if(i < self.len() - 1) {
						io::printn(",");
				} else {
						io::printn("");
				}
		}
		io::print("]");
}

enum StatementKind {
		VAR_DECL,
		VAR_ASSIGN,
		RETURN,
}

union StatementData {
	   VarDeclStatement varDecl;
	   VarAssignStatement varAssign;
	   ExpressionASTNode* ret;
}

struct StatementASTNode {
		StatementKind kind;
		StatementData as;
}

fn void StatementASTNode.show(self, String src) {
		switch(self.kind) {
				case StatementKind.VAR_DECL:
						io::printf("{\n\"var decl `%s`\": {\n\"type\": ", self.as.varDecl.name.as.ident);
						self.as.varDecl.type.show();
						io::printf(",\n\"value\": ");
						self.as.varDecl.val.show(src);
						io::print("\n}\n}");
				case StatementKind.RETURN:
						io::printf("{\n\"return\": ");
						self.as.ret.show(src);
						io::print("\n}");
				case StatementKind.VAR_ASSIGN:
						io::printfn("{\n\"var assign `%s`\": {", self.as.varAssign.name.as.ident);
						io::printf("\"value\": ");
						self.as.varAssign.val.show(src);
						io::print("\n}\n}");
		}
}

macro newStatement(kind, as) => StatementASTNode {
		kind = kind,
		as = as,
};

macro newReturnStatement(expr) => newStatement(StatementKind.RETURN, StatementData {
		ret = expr
});

struct VarDeclStatement {
		Token name;
		Type* type;
		ExpressionASTNode* val;
}

macro newVarDeclStatement(name, type, value) => newStatement(StatementKind.VAR_DECL, StatementData {
	varDecl = VarDeclStatement {
		name = name,
		type = type,
		val = value,
	}
});

struct VarAssignStatement {
		Token name;
		ExpressionASTNode* val;
}

macro newVarAssignStatement(name, value) => newStatement(StatementKind.VAR_ASSIGN, StatementData {
	varAssign = VarAssignStatement {
		name = name,
		val = value,
	}
});

enum ExpressionKind {
		UNIT,
		INT_LITERAL,
		BOOL_LITERAL,
		IDENTIFIER,
		PREFIX,
		POSTFIX,
		BINARY,
}

union ExpressionData {
		TokenSpan unit;
		Token intLit;
		Token ident;
		Token boolLit;
		PrefixExpression prefix;
		PostfixExpression postfix;
		BinaryExpression binary;
}

struct ExpressionASTNode {
		ExpressionKind kind;
		ExpressionData as;
}

fn void ExpressionASTNode.show(&self, String src) {
		switch(self.kind) {
				case ExpressionKind.UNIT:
						io::print("{}");
				case ExpressionKind.INT_LITERAL:
						io::printf("{\n\"int literal\": %d\n}", self.as.intLit.as.intLit);
				case ExpressionKind.BOOL_LITERAL:
						io::printf("{\n\"bool literal\": %s\n}", self.as.boolLit.toString(src));
				case ExpressionKind.IDENTIFIER:
						io::printf("{\n\"identifier\": \"%s\"\n}", self.as.ident.as.ident);
				case ExpressionKind.PREFIX:
						io::printfn("{\n\"prefix\": \"%s\",", self.as.prefix.op.toString(src));
						io::print("\"value\": ");
						self.as.prefix.operand.show(src);
						io::printf("}");
				case ExpressionKind.POSTFIX:
						io::printfn("{\n\"postfix\": \"%s\",", self.as.postfix.op.toString(src));
						io::print("\"value\": ");
						self.as.postfix.operand.show(src);
						io::printf("}");
				case ExpressionKind.BINARY:
						io::printfn("{\n\"binary\": \"%s\",", self.as.binary.op.toString(src));
						io::print("\"left\": ");
						self.as.binary.left.show(src);
						io::printn(",");
						io::print("\"right\": ");
						self.as.binary.right.show(src);
						io::printf("}");
		}
}

macro newExpr(kind, data) => mem::new(ExpressionASTNode, {
		kind = kind,
		as = data,
});

macro newUnitExpr(TokenSpan next) => newExpr(ExpressionKind.UNIT, ExpressionData {
		unit = span::new(next.start, next.start + 1),
});

macro newIntLitExpr(lit) => newExpr(ExpressionKind.INT_LITERAL, ExpressionData {
		intLit = lit,
});

macro newBoolLitExpr(lit) => newExpr(ExpressionKind.BOOL_LITERAL, ExpressionData {
		boolLit = lit,
});

macro newIdentifierExpr(ident) => newExpr(ExpressionKind.IDENTIFIER, ExpressionData {
		ident = ident,
});

struct PrefixExpression {
		Token op;
		ExpressionASTNode *operand;
}

macro newPrefixExpr(op, operand) => newExpr(ExpressionKind.PREFIX, ExpressionData {
	prefix = PrefixExpression {
		op = op,
		operand = operand,
	}
});

struct PostfixExpression {
		Token op;
		ExpressionASTNode *operand;
}

macro newPostfixExpr(op, operand) => newExpr(ExpressionKind.POSTFIX, ExpressionData {
	postfix = PostfixExpression {
		op = op,
		operand = operand,
	}
});

struct BinaryExpression {
		Token op;
		ExpressionASTNode *left;
		ExpressionASTNode *right;
}

macro newBinopExpr(op, left, right) => newExpr(ExpressionKind.BINARY, ExpressionData {
	binary = BinaryExpression {
		op = op,
		left = left,
		right = right,
	}
});

struct GlobalDeclASTNode {
		Token name;
		ExpressionASTNode *value;
		Type* type;
}

macro newGlobalNode(name, value, type) => newASTNode(ASTKind.GLOBAL_DECL, ASTData {
	globalDecl = GlobalDeclASTNode {
		name = name,
		value = value,
		type = type,
	}
});

alias ParamList = List{ FunctionParam };

struct FunctionDeclASTNode {
		Token name;
		ParamList params;
		Type* returnType;
		Block body;
}

macro newFunctionNode(name, params, returnType, body) => newASTNode(ASTKind.FUNCTION_DECL, ASTData {
	functionDecl = FunctionDeclASTNode {
		name = name,
		params = params,
		returnType = returnType,
		body = body,
	}
});

struct FunctionParam {
		Token name;
		Type* type;
}

macro newFunctionParam(name, type) => FunctionParam {
		name = name,
		type = type,
};

enum TypeKind {
		IDENTIFIER,
		REF,
		CONST,
		ARRAY,
}

union TypeData {
		Token ident;
		Type* ref;
		Type* constant;
		TypeArray array;
}

struct Type {
		TypeKind kind;
		TypeData as;
}

struct TypeArray {
		Type* type;
		usz dim;
}

fn void Type.show(&self) {
		switch(self.kind) {
				case TypeKind.IDENTIFIER:
						io::printf("{\n\"name\": \"%s\"\n}", self.as.ident.as.ident);
				case TypeKind.REF:
						io::printfn("{\n\"ref\": ");
						self.as.ref.show();
						io::printf("\n}");
				case TypeKind.CONST:
						io::printfn("{\n\"const\": ");
						self.as.constant.show();
						io::printf("\n}");
				case TypeKind.ARRAY:
						io::printfn("{\n\"array\": ");
						self.as.array.type.show();
						io::printf("\n\"size\": %d\n}", self.as.array.dim);
		}
}

macro newType(kind, data) => mem::new(Type, {
		kind = kind,
		as = data,
});

macro newTypeIdent(ident) => newType(TypeKind.IDENTIFIER, TypeData {
	ident = ident
});

macro newRefType(type) => newType(TypeKind.REF, TypeData {
	ref = type
});

macro newConstType(type) => newType(TypeKind.CONST, TypeData {
	constant = type
});

macro newArrayType(type, dim) => newType(TypeKind.ARRAY, TypeData {
	array = TypeArray {
		type = type,
		dim = dim
	}
});
