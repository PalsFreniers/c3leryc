module lery::lexer::tests;
import lery::lexer::token;

macro void expectToken(Lexer *lexer, TokenType $expected) {
        TokenType tmp = lexer.next().type;
        assert(tmp == $expected, "Expected token type: " +++ $expected.nameof +++ ", but got: %s", tmp.nameof);
}

fn void globalVarDecl() @test {
        String input = "global x: u32 = 4;\nglobal y: u32;";
        Lexer lexer = lexer::new(input);
        expectToken(&lexer, TokenType.GLOBAL);
        expectToken(&lexer, TokenType.IDENTIFIER);
        expectToken(&lexer, TokenType.COLON);
        expectToken(&lexer, TokenType.IDENTIFIER);
        expectToken(&lexer, TokenType.ASSIGNMENT);
        expectToken(&lexer, TokenType.INT_LITERAL);
        expectToken(&lexer, TokenType.SEMICOLON);
        expectToken(&lexer, TokenType.GLOBAL);
        expectToken(&lexer, TokenType.IDENTIFIER);
        expectToken(&lexer, TokenType.COLON);
        expectToken(&lexer, TokenType.IDENTIFIER);
        expectToken(&lexer, TokenType.ASSIGNMENT);
        expectToken(&lexer, TokenType.INT_LITERAL);
        expectToken(&lexer, TokenType.SEMICOLON);
        expectToken(&lexer, TokenType.END_OF_FILE);
}
