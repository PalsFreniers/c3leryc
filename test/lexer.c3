module lery::lexer::tests;
import lery::lexer::token;

macro void Lexer.expectTokenInt(&lexer, int val) {
        Token tmp = lexer.next()!!;
        assert(tmp.type == TokenType.INT_LITERAL, "Expected token type: %s, but got: %s", TokenType.INT_LITERAL.nameof, tmp.type.nameof);
        assert(tmp.as.intLit == val, "Expected TokenValue: %d but got %d", val, tmp.as.intLit);
}

macro void Lexer.expectTokenIdent(&lexer, String val) {
        Token tmp = lexer.next()!!;
        assert(tmp.type == TokenType.IDENTIFIER, "Expected token type: %s, but got: %s", TokenType.IDENTIFIER.nameof, tmp.type.nameof);
        assert(tmp.toString(lexer.program) == val, "Expected TokenValue: %s but got %s", val, tmp.toString(lexer.program));
}

macro void Lexer.expectToken(&lexer, TokenType $expected) {
        TokenType tmp = lexer.next()!!.type;
        assert(tmp == $expected, "Expected token type: %s, but got: %s", $expected.nameof, tmp.nameof);
}

macro void Lexer.expectFault(&lexer, anyfault $expected) {
        Token! tmp1 = lexer.next();
        assert(!@ok(tmp1), "Expected fault, but got a token: %s", tmp1!!.type.nameof);
        anyfault tmp = @catch(tmp1);
        assert(tmp == $expected, "Expected fault type: %s, but got: %s", $expected.nameof, tmp.nameof);
}

fn void globalVarDecl() @test {
        String input = "global x: u32 = 4;\nglobal y: u32;";
        Lexer lexer = lexer::new(input);
        lexer.expectToken(TokenType.GLOBAL);
        lexer.expectTokenIdent("x");
        lexer.expectToken(TokenType.COLON);
        lexer.expectTokenIdent("u32");
        lexer.expectToken(TokenType.ASSIGNMENT);
        lexer.expectTokenInt(4);
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.GLOBAL);
        lexer.expectTokenIdent("y");
        lexer.expectToken(TokenType.COLON);
        lexer.expectTokenIdent("u32");
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.END_OF_FILE);
}

fn void commentsSingleLine() @test {
        String input = "// This is a single line comment\nx = 5;";
        Lexer lexer = lexer::new(input);
        lexer.expectTokenIdent("x");
        lexer.expectToken(TokenType.ASSIGNMENT);
        lexer.expectTokenInt(5);
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.END_OF_FILE);
}

fn void commentsMultiLine() @test {
        String input = "/{ This is a multi\nline comment }/\nx = 5;";
        Lexer lexer = lexer::new(input);
        lexer.expectTokenIdent("x");
        lexer.expectToken(TokenType.ASSIGNMENT);
        lexer.expectTokenInt(5);
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.END_OF_FILE);
}

fn void functionDecl() @test {
        String input = "fn myFunction(x: u32) -> u32 {\n\tsquared: u32 = x ** 2;\n\treturn x;\n}";
        Lexer lexer = lexer::new(input);
        lexer.expectToken(TokenType.FUNCTION);
        lexer.expectTokenIdent("myFunction");
        lexer.expectToken(TokenType.LEFT_PAREN);
        lexer.expectTokenIdent("x");
        lexer.expectToken(TokenType.COLON);
        lexer.expectTokenIdent("u32");
        lexer.expectToken(TokenType.RIGHT_PAREN);
        lexer.expectToken(TokenType.RIGHT_ARROW);
        lexer.expectTokenIdent("u32");
        lexer.expectToken(TokenType.LEFT_BRACKET);
        lexer.expectTokenIdent("squared");
        lexer.expectToken(TokenType.COLON);
        lexer.expectTokenIdent("u32");
        lexer.expectToken(TokenType.ASSIGNMENT);
        lexer.expectTokenIdent("x");
        lexer.expectToken(TokenType.EXPONENT);
        lexer.expectTokenInt(2);
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.RETURN);
        lexer.expectTokenIdent("x");
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.RIGHT_BRACKET);
        lexer.expectToken(TokenType.END_OF_FILE);
}

fn void signleLineProgram() @test {
        String input = "x = 5;";
        Lexer lexer = lexer::new(input);
        lexer.expectTokenIdent("x");
        lexer.expectToken(TokenType.ASSIGNMENT);
        lexer.expectTokenInt(5);
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.END_OF_FILE);
}

fn void singleLineInvalidProgram() @test {
        String input = "1dsfj";
        Lexer lexer = lexer::new(input);
        lexer.expectFault(LexerFault.INVALID_INTEGER_LITERAL);
}

fn void allSyntax() @test {
        String input = "global fn return if elif else while for break continue do try catch finally throw switch case default import module class method property static get set operator cast implements extends interface enum struct bitstruct union bitunion type bit define namespace use new delete alias ref const as instanceof typeof sizeof = : ; , . -> ( ) { } [ ] + += =+ - -= =- * *= =* / /= =/ % %= =% ** **= =** ++ -- | |= =| & &= =& ^ ^= =^ ~ ~~ ~| |~ ~|= |~= =~| =|~ ~& &~ ~&= &~= =~& =&~ ~^ ^~ ~^= ^~= =~^ =^~ << <<= =<< >> >>= =>> ! || && == != =! < > <= =< >= => 123 test /{\nmulti line comment \n}/ \n// comment on line\n456";
        Lexer lexer = lexer::new(input);
        lexer.expectToken(TokenType.GLOBAL);
        lexer.expectToken(TokenType.FUNCTION);
        lexer.expectToken(TokenType.RETURN);
        lexer.expectToken(TokenType.IF);
        lexer.expectToken(TokenType.ELIF);
        lexer.expectToken(TokenType.ELSE);
        lexer.expectToken(TokenType.WHILE);
        lexer.expectToken(TokenType.FOR);
        lexer.expectToken(TokenType.BREAK);
        lexer.expectToken(TokenType.CONTINUE);
        lexer.expectToken(TokenType.DO);
        lexer.expectToken(TokenType.TRY);
        lexer.expectToken(TokenType.CATCH);
        lexer.expectToken(TokenType.FINALLY);
        lexer.expectToken(TokenType.THROW);
        lexer.expectToken(TokenType.SWITCH);
        lexer.expectToken(TokenType.CASE);
        lexer.expectToken(TokenType.DEFAULT);
        lexer.expectToken(TokenType.IMPORT);
        lexer.expectToken(TokenType.MODULE);
        lexer.expectToken(TokenType.CLASS);
        lexer.expectToken(TokenType.METHOD);
        lexer.expectToken(TokenType.PROPERTY);
        lexer.expectToken(TokenType.STATIC);
        lexer.expectToken(TokenType.GET);
        lexer.expectToken(TokenType.SET);
        lexer.expectToken(TokenType.OPERATOR);
        lexer.expectToken(TokenType.CAST);
        lexer.expectToken(TokenType.IMPLEMENTS);
        lexer.expectToken(TokenType.EXTENDS);
        lexer.expectToken(TokenType.INTERFACE);
        lexer.expectToken(TokenType.ENUM);
        lexer.expectToken(TokenType.STRUCT);
        lexer.expectToken(TokenType.BITSTRUCT);
        lexer.expectToken(TokenType.UNION);
        lexer.expectToken(TokenType.BITUNION);
        lexer.expectToken(TokenType.TYPE);
        lexer.expectToken(TokenType.BITS);
        lexer.expectToken(TokenType.DEFINE);
        lexer.expectToken(TokenType.NAMESPACE);
        lexer.expectToken(TokenType.USE);
        lexer.expectToken(TokenType.NEW);
        lexer.expectToken(TokenType.DELETE);
        lexer.expectToken(TokenType.ALIAS);
        lexer.expectToken(TokenType.REF);
        lexer.expectToken(TokenType.CONST);
        lexer.expectToken(TokenType.AS);
        lexer.expectToken(TokenType.INSTANCEOF);
        lexer.expectToken(TokenType.TYPEOF);
        lexer.expectToken(TokenType.SIZEOF);
        lexer.expectToken(TokenType.ASSIGNMENT);
        lexer.expectToken(TokenType.COLON);
        lexer.expectToken(TokenType.SEMICOLON);
        lexer.expectToken(TokenType.COMMA);
        lexer.expectToken(TokenType.DOT);
        lexer.expectToken(TokenType.RIGHT_ARROW);
        lexer.expectToken(TokenType.LEFT_PAREN);
        lexer.expectToken(TokenType.RIGHT_PAREN);
        lexer.expectToken(TokenType.LEFT_BRACKET);
        lexer.expectToken(TokenType.RIGHT_BRACKET);
        lexer.expectToken(TokenType.LEFT_BRACE);
        lexer.expectToken(TokenType.RIGHT_BRACE);
        lexer.expectToken(TokenType.PLUS);
        lexer.expectToken(TokenType.PLUS_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_PLUS);
        lexer.expectToken(TokenType.MINUS);
        lexer.expectToken(TokenType.MINUS_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_MINUS);
        lexer.expectToken(TokenType.STAR);
        lexer.expectToken(TokenType.STAR_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_STAR);
        lexer.expectToken(TokenType.SLASH);
        lexer.expectToken(TokenType.SLASH_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_SLASH);
        lexer.expectToken(TokenType.MODULUS);
        lexer.expectToken(TokenType.MODULUS_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_MODULUS);
        lexer.expectToken(TokenType.EXPONENT);
        lexer.expectToken(TokenType.EXPONENT_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_EXPONENT);
        lexer.expectToken(TokenType.INCREMENT);
        lexer.expectToken(TokenType.DECREMENT);
        lexer.expectToken(TokenType.OR);
        lexer.expectToken(TokenType.OR_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_OR);
        lexer.expectToken(TokenType.AND);
        lexer.expectToken(TokenType.AND_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_AND);
        lexer.expectToken(TokenType.XOR);
        lexer.expectToken(TokenType.XOR_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_XOR);
        lexer.expectToken(TokenType.NOT);
        lexer.expectToken(TokenType.NOTCREMENT);
        lexer.expectToken(TokenType.NOR);
        lexer.expectToken(TokenType.NOR);
        lexer.expectToken(TokenType.NOR_ASSIGN);
        lexer.expectToken(TokenType.NOR_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_NOR);
        lexer.expectToken(TokenType.ASSIGN_NOR);
        lexer.expectToken(TokenType.NAND);
        lexer.expectToken(TokenType.NAND);
        lexer.expectToken(TokenType.NAND_ASSIGN);
        lexer.expectToken(TokenType.NAND_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_NAND);
        lexer.expectToken(TokenType.ASSIGN_NAND);
        lexer.expectToken(TokenType.NXOR);
        lexer.expectToken(TokenType.NXOR);
        lexer.expectToken(TokenType.NXOR_ASSIGN);
        lexer.expectToken(TokenType.NXOR_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_NXOR);
        lexer.expectToken(TokenType.ASSIGN_NXOR);
        lexer.expectToken(TokenType.SHIFT_LEFT);
        lexer.expectToken(TokenType.SHIFT_LEFT_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_SHIFT_LEFT);
        lexer.expectToken(TokenType.SHIFT_RIGHT);
        lexer.expectToken(TokenType.SHIFT_RIGHT_ASSIGN);
        lexer.expectToken(TokenType.ASSIGN_SHIFT_RIGHT);
        lexer.expectToken(TokenType.BOOL_NOT);
        lexer.expectToken(TokenType.BOOL_OR);
        lexer.expectToken(TokenType.BOOL_AND);
        lexer.expectToken(TokenType.EQUAL);
        lexer.expectToken(TokenType.NOT_EQUAL);
        lexer.expectToken(TokenType.NOT_EQUAL);
        lexer.expectToken(TokenType.LESS_THAN);
        lexer.expectToken(TokenType.GREATER_THAN);
        lexer.expectToken(TokenType.LESS_EQUAL);
        lexer.expectToken(TokenType.LESS_EQUAL);
        lexer.expectToken(TokenType.GREATER_EQUAL);
        lexer.expectToken(TokenType.GREATER_EQUAL);
        lexer.expectTokenInt(123);
        lexer.expectTokenIdent("test");
        lexer.expectTokenInt(456);
        lexer.expectToken(TokenType.END_OF_FILE);
}
