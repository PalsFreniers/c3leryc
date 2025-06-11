module lery::parser::tests;
import std::io;
import lery::parser;
import lery::lexer;

fn Parser! generateParserFromSource(String src) {
        Lexer l = lexer::new(src);
        TokenList list;
        list.new_init();
        list.collect(&l)!;
        return parser::new(list, src);
}

fn void testEmptyParser() @test {
        String src = "";
        Parser p = generateParserFromSource(src)!!;
        Program prog = p.parse()!!;
        assert(prog.len() == 0, "Program should not have error and should be empty");
}


fn void testSimpleGlobalNoExpr() @test {
        String src = "global x: u32;";
        Parser p = generateParserFromSource(src)!!;
        Program prog = p.parse()!!;
        assert(prog.len() == 1, "Program should contain one value");
        assert(prog[0].kind == ASTKind.GLOBAL_DECL, "Program should contain one global declaration");
        assert(prog[0].as.globalDecl.name.toString(src) == "x", "global name should be `x`");
        assert(prog[0].as.globalDecl.value == null, "there should not be any value linked to this variable");
        assert(prog[0].as.globalDecl.type.as.ident.toString(src) == "u32", "type should be `u32`");
        assert(!prog[0].as.globalDecl.type.isConst, "type should not be constant");
        assert(!prog[0].as.globalDecl.type.isRef, "type should not be a reference");
        assert(prog[0].as.globalDecl.type.dim == 0, "type should not be an array");
}

fn void testSimpleGlobalsimpleExpr() @test {
        String src = "global x: u32 = 15 * 2;";
        Parser p = generateParserFromSource(src)!!;
        Program prog = p.parse()!!;
        assert(prog.len() == 1, "Program should contain one value");
        assert(prog[0].kind == ASTKind.GLOBAL_DECL, "Program should contain one global declaration");
        assert(prog[0].as.globalDecl.name.toString(src) == "x", "global name should be `x`");
        assert(prog[0].as.globalDecl.value != null, "there should be a value linked to this variable");
        ExpressionASTNode* expr = prog[0].as.globalDecl.value;
        assert(expr.kind == ExpressionKind.BINARY, "`15 * 2` is binary operation");
        assert(expr.as.binary.op.type == TokenType.STAR, "`15 * 2` is star operator");
        expr = expr.as.binary.left;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`15` is an integer");
        assert(expr.as.intLit.as.intLit == 15, "`15` != 15");
        expr = prog[0].as.globalDecl.value.as.binary.right;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`2` is an integer");
        assert(expr.as.intLit.as.intLit == 2, "`2` != 2");
        assert(prog[0].as.globalDecl.type.as.ident.toString(src) == "u32", "type should be `u32`");
        assert(!prog[0].as.globalDecl.type.isConst, "type should not be constant");
        assert(!prog[0].as.globalDecl.type.isRef, "type should not be a reference");
        assert(prog[0].as.globalDecl.type.dim == 0, "type should not be an array");
}

fn void testSimpleGlobalDoubleExpr() @test {
        String src = "global x: u32 = 4 + 15 * 2;";
        Parser p = generateParserFromSource(src)!!;
        Program prog = p.parse()!!;
        assert(prog.len() == 1, "Program should contain one value");
        assert(prog[0].kind == ASTKind.GLOBAL_DECL, "Program should contain one global declaration");
        assert(prog[0].as.globalDecl.name.toString(src) == "x", "global name should be `x`");
        assert(prog[0].as.globalDecl.value != null, "there should be a value linked to this variable");
        ExpressionASTNode* expr = prog[0].as.globalDecl.value;
        assert(expr.kind == ExpressionKind.BINARY, "`4 + 15 * 2` is binary operation");
        assert(expr.as.binary.op.type == TokenType.PLUS, "`4 + 15 * 2` is plus operator");
        expr = expr.as.binary.left;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`4` is an integer");
        assert(expr.as.intLit.as.intLit == 4, "`4` != 4");
        expr = prog[0].as.globalDecl.value.as.binary.right;
        assert(expr.kind == ExpressionKind.BINARY, "`15 * 2` is binary operation");
        assert(expr.as.binary.op.type == TokenType.STAR, "`15 * 2` is star operator");
        expr = expr.as.binary.left;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`15` is an integer");
        assert(expr.as.intLit.as.intLit == 15, "`15` != 15");
        expr = prog[0].as.globalDecl.value.as.binary.right.as.binary.right;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`2` is an integer");
        assert(expr.as.intLit.as.intLit == 2, "`2` != 2");
        assert(prog[0].as.globalDecl.type.as.ident.toString(src) == "u32", "type should be `u32`");
        assert(!prog[0].as.globalDecl.type.isConst, "type should not be constant");
        assert(!prog[0].as.globalDecl.type.isRef, "type should not be a reference");
        assert(prog[0].as.globalDecl.type.dim == 0, "type should not be an array");
}

fn void testSimpleGlobalTripleExpr() @test {
        String src = "global x: u32 = 2 / 4 + 15 * 2;";
        Parser p = generateParserFromSource(src)!!;
        Program prog = p.parse()!!;
        assert(prog.len() == 1, "Program should contain one value");
        assert(prog[0].kind == ASTKind.GLOBAL_DECL, "Program should contain one global declaration");
        assert(prog[0].as.globalDecl.name.toString(src) == "x", "global name should be `x`");
        assert(prog[0].as.globalDecl.value != null, "there should be a value linked to this variable");
        ExpressionASTNode* expr = prog[0].as.globalDecl.value;
        assert(expr.kind == ExpressionKind.BINARY, "`2 / 4 + 15 * 2` is binary operation");
        assert(expr.as.binary.op.type == TokenType.PLUS, "`2 / 4 + 15 * 2` is plus operator");
        expr = expr.as.binary.left;
        assert(expr.kind == ExpressionKind.BINARY, "`2 / 4` is binary operation");
        assert(expr.as.binary.op.type == TokenType.SLASH, "`2 / 4` is slash operator");
        expr = expr.as.binary.left;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`2` is an integer");
        assert(expr.as.intLit.as.intLit == 2, "`2` != 2 (got %d)", expr.as.intLit.as.intLit);
        expr = prog[0].as.globalDecl.value.as.binary.left.as.binary.right;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`4` is an integer");
        assert(expr.as.intLit.as.intLit == 4, "`4` != 4 (got %d)", expr.as.intLit.as.intLit);
        expr = prog[0].as.globalDecl.value.as.binary.right;
        assert(expr.kind == ExpressionKind.BINARY, "`15 * 2` is binary operation");
        assert(expr.as.binary.op.type == TokenType.STAR, "`15 * 2` is star operator");
        expr = expr.as.binary.left;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`15` is an integer");
        assert(expr.as.intLit.as.intLit == 15, "`15` != 15 (got %d)", expr.as.intLit.as.intLit);
        expr = prog[0].as.globalDecl.value.as.binary.right.as.binary.right;
        assert(expr.kind == ExpressionKind.INT_LITERAL, "`2` is an integer");
        assert(expr.as.intLit.as.intLit == 2, "`2` != 2 (got %d)", expr.as.intLit.as.intLit);
        assert(prog[0].as.globalDecl.type.as.ident.toString(src) == "u32", "type should be `u32`");
        assert(!prog[0].as.globalDecl.type.isConst, "type should not be constant");
        assert(!prog[0].as.globalDecl.type.isRef, "type should not be a reference");
        assert(prog[0].as.globalDecl.type.dim == 0, "type should not be an array");
}
