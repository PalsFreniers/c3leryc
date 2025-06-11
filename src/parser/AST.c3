module lery::parser::ast;
import lery::lexer;
import std::collections::list;

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

macro newASTNode(kind, data) => ASTNode {
        .kind = kind,
        .as = data,
};

def Program = list::List(<ASTNode>);
def Block   = list::List(<StatementASTNode>);

enum StatementKind {
        VAR_DECL,
        VAR_ASSIGN,
        FUNCTION_CALL,
}

struct StatementData {
       VarDeclStatement varDecl;
}

struct StatementASTNode {
        StatementKind kind;
        StatementData as;
}

macro newStatement(kind, as) => StatementASTNode {
        .kind = kind,
        .as = as,
};

struct VarDeclStatement {
        Token name;
        ExpressionASTNode* val;
}

macro newVarDeclStatement(name, value) => newStatement(StatementKind.VAR_DECL, VarDeclStatement {
        .name = name,
        .val = value,
});

enum ExpressionKind {
        INT_LITERAL,
        PREFIX,
        POSTFIX,
        BINARY,
}

union ExpressionData {
        Token intLit;
        PrefixExpression prefix;
        PostfixExpression postfix;
        BinaryExpression binary;
}

struct ExpressionASTNode {
        ExpressionKind kind;
        ExpressionData as;
}

macro newExpr(kind, data) => mem::new(ExpressionASTNode, {
        .kind = kind,
        .as = data,
});

macro newIntLitExpr(lit) => newExpr(ExpressionKind.INT_LITERAL, ExpressionData {
        .intLit = lit,
});

struct PrefixExpression {
        Token op;
        ExpressionASTNode *operand;
}

macro newPrefixExpr(op, operand) => newExpr(ExpressionKind.PREFIX, ExpressionData {.prefix = PrefixExpression {
        .op = op,
        .operand = operand,
}});

struct PostfixExpression {
        Token op;
        ExpressionASTNode *operand;
}

macro newPostfixExpr(op, operand) => newExpr(ExpressionKind.POSTFIX, ExpressionData {.postfix = PostfixExpression {
        .op = op,
        .operand = operand,
}});

struct BinaryExpression {
        Token op;
        ExpressionASTNode *left;
        ExpressionASTNode *right;
}

macro newBinopExpr(op, left, right) => newExpr(ExpressionKind.BINARY, ExpressionData {.binary = BinaryExpression {
        .op = op,
        .left = left,
        .right = right,
}});

struct GlobalDeclASTNode {
        Token name;
        ExpressionASTNode *value;
        Type type;
}

macro newGlobalNode(name, value, type) => newASTNode(ASTKind.GLOBAL_DECL, ASTData {.globalDecl = GlobalDeclASTNode {
        .name = name,
        .value = value,
        .type = type,
}});

def ParamList = list::List(<FunctionParam>);

struct FunctionDeclASTNode {
        Token name;
        ParamList params;
        Type returnType;
        Block body;
}

macro newFunctionNode(name, params, returnType, body) => newASTNode(ASTKind.FUNCTION, ASTData {.functionDecl = FunctionDeclASTNode {
        .name = name,
        .params = params,
        .returnType = returnType,
        .body = body,
}});

struct FunctionParam {
        Token name;
        Type type;
}

macro newFunctionParam(name, type) => FunctionParam {
        .name = name,
        .type = type,
};

enum TypeKind {
        IDENTIFIER,
}

union TypeData {
        Token ident;
}

struct Type {
        TypeKind kind;
        TypeData as;
        usz dim;
        bool isRef;
        bool isConst;
}

macro newType(kind, data, dim, isRef, isConst) => Type {
        .kind = kind,
        .as = data,
        .dim = dim,
        .isRef = isRef,
        .isConst = isConst,
};

macro newTypeIdent(ident, dim, isRef, isConst) => newType(TypeKind.IDENTIFIER, TypeData {.ident = ident}, dim, isRef, isConst);
