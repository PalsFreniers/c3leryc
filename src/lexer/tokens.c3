module lery::lexer::token;

enum TokenType {
        // KEYWORDS
        GLOBAL,             // [x] global
        FUNCTION,           // [x] fn
        RETURN,             // [x] return
        IF,                 // [x] if
        ELIF,               // [x] elif
        ELSE,               // [x] else
        WHILE,              // [x] while
        FOR,                // [x] for
        BREAK,              // [x] break
        CONTINUE,           // [x] continue
        DO,                 // [x] do
        TRY,                // [x] try
        CATCH,              // [x] catch
        FINALLY,            // [x] finally
        THROW,              // [x] throw
        SWITCH,             // [x] switch
        CASE,               // [x] case
        DEFAULT,            // [x] default
        IMPORT,             // [x] import
        MODULE,             // [x] module
        CLASS,              // [x] class
        METHOD,             // [x] method
        PROPERTY,           // [x] property
        STATIC,             // [x] static
        GET,                // [x] get
        SET,                // [x] set
        OPERATOR,           // [x] operator
        CAST,               // [x] cast
        IMPLEMENTS,         // [x] implements
        EXTENDS,            // [x] extends
        INTERFACE,          // [x] interface
        ENUM,               // [x] enum
        STRUCT,             // [x] struct
        BITSTRUCT,          // [x] bitstruct
        UNION,              // [x] union
        BITUNION,           // [x] bitunion
        TYPE,               // [x] type
        BITS,               // [x] bit
        DEFINE,             // [x] define
        NAMESPACE,          // [x] namespace
        USE,                // [x] use
        NEW,                // [x] new
        DELETE,             // [x] delete
        ALIAS,              // [x] alias
        REF,                // [x] ref
        CONST,              // [x] const
        AS,                 // [x] as
        INSTANCEOF,         // [x] instanceof
        TYPEOF,             // [x] typeof
        SIZEOF,             // [x] sizeof
        // GLOBAL SYNTAX 
        ASSIGNMENT,         // [x] =
        COLON,              // [x] :
        SEMICOLON,          // [x] ;
        COMMA,              // [x] ,
        DOT,                // [x] .
        RIGHT_ARROW,        // [x] ->
        LEFT_PAREN,         // [x] (
        RIGHT_PAREN,        // [x] )
        LEFT_BRACKET,       // [x] {
        RIGHT_BRACKET,      // [x] }
        LEFT_BRACE,         // [x] [
        RIGHT_BRACE,        // [x] ]
        // OPERATORS
        //// ARITHEMTICS    
        PLUS,               // [x] +
        PLUS_ASSIGN,        // [x] +=
        ASSIGN_PLUS,        // [x] =+
        MINUS,              // [x] -
        MINUS_ASSIGN,       // [x] -=
        ASSIGN_MINUS,       // [x] =-
        STAR,               // [x] *
        STAR_ASSIGN,        // [x] *=
        ASSIGN_STAR,        // [x] =*
        SLASH,              // [x] /
        SLASH_ASSIGN,       // [x] /=
        ASSIGN_SLASH,       // [x] =/
        MODULUS,            // [x] %
        MODULUS_ASSIGN,     // [x] %=
        ASSIGN_MODULUS,     // [x] =%
        EXPONENT,           // [x] **
        EXPONENT_ASSIGN,    // [x] **=
        ASSIGN_EXPONENT,    // [x] =**
        INCREMENT,          // [x] ++
        DECREMENT,          // [x] --
        //// BITWISE
        OR,                 // [x] |
        OR_ASSIGN,          // [x] |=
        ASSIGN_OR,          // [x] =|
        AND,                // [x] &
        AND_ASSIGN,         // [x] &=
        ASSIGN_AND,         // [x] =&
        XOR,                // [x] ^
        XOR_ASSIGN,         // [x] ^=
        ASSIGN_XOR,         // [x] =^
        NOT,                // [x] ~
        NOTCREMENT,         // [x] ~~
        NOR,                // [x] ~|  / [x] |~
        NOR_ASSIGN,         // [x] ~|= / [x] |~=
        ASSIGN_NOR,         // [x] =~| / [x] =|~
        NAND,               // [x] ~&  / [x] &~
        NAND_ASSIGN,        // [x] ~&= / [x] &~=
        ASSIGN_NAND,        // [x] =~& / [x] =&~
        NXOR,               // [x] ~^  / [x] ^~
        NXOR_ASSIGN,        // [x] ~^= / [x] ^~=
        ASSIGN_NXOR,        // [x] =~^ / [x] =^~
        SHIFT_LEFT,         // [x] <<
        SHIFT_LEFT_ASSIGN,  // [x] <<=
        ASSIGN_SHIFT_LEFT,  // [x] =<<
        SHIFT_RIGHT,        // [x] >>
        SHIFT_RIGHT_ASSIGN, // [x] >>=
        ASSIGN_SHIFT_RIGHT, // [x] =>>
        //// COMPARISON
        BOOL_NOT,           // [x] !
        BOOL_OR,            // [x] ||
        BOOL_AND,           // [x] &&
        EQUAL,              // [x] ==
        NOT_EQUAL,          // [x] != / [x] =!
        LESS_THAN,          // [x] <
        GREATER_THAN,       // [x] >
        LESS_EQUAL,         // [x] <= / [x] =<
        GREATER_EQUAL,      // [x] >= / [x] =>
        // LITERALS
        INT_LITERAL,        // [x]
        // ELSE
        IDENTIFIER,         // [x]
        END_OF_FILE,        // [x]
}

union TokenValue {
        usz intLit;
        String ident;
}

struct Token {
        TokenType type;
        LexerLoc loc;
        TokenSpan span;
        TokenValue as;
}

fn String Token.toString(self, String src) {
        return src[self.span.start .. self.span.end - 1];
}

fn Token new(TokenType type, LexerLoc loc = {}, TokenSpan span = {}, TokenValue as = {}) => Token { .type = type, .loc = loc, .span = span, .as = as };

fn TokenType getKeyword(String name) {
        switch (name) {
                case "global": return TokenType.GLOBAL;
                case "fn": return TokenType.FUNCTION;
                case "return": return TokenType.RETURN;
                case "if": return TokenType.IF;
                case "elif": return TokenType.ELIF;
                case "else": return TokenType.ELSE;
                case "while": return TokenType.WHILE;
                case "for": return TokenType.FOR;
                case "break": return TokenType.BREAK;
                case "continue": return TokenType.CONTINUE;
                case "do": return TokenType.DO;
                case "try": return TokenType.TRY;
                case "catch": return TokenType.CATCH;
                case "finally": return TokenType.FINALLY;
                case "throw": return TokenType.THROW;
                case "switch": return TokenType.SWITCH;
                case "case": return TokenType.CASE;
                case "default": return TokenType.DEFAULT;
                case "import": return TokenType.IMPORT;
                case "module": return TokenType.MODULE;
                case "class": return TokenType.CLASS;
                case "method": return TokenType.METHOD;
                case "property": return TokenType.PROPERTY;
                case "static": return TokenType.STATIC;
                case "get": return TokenType.GET;
                case "set": return TokenType.SET;
                case "operator": return TokenType.OPERATOR;
                case "cast": return TokenType.CAST;
                case "implements": return TokenType.IMPLEMENTS;
                case "extends": return TokenType.EXTENDS;
                case "interface": return TokenType.INTERFACE;
                case "enum": return TokenType.ENUM;
                case "struct": return TokenType.STRUCT;
                case "bitstruct": return TokenType.BITSTRUCT;
                case "union": return TokenType.UNION;
                case "bitunion": return TokenType.BITUNION;
                case "type": return TokenType.TYPE;
                case "bit": return TokenType.BITS;
                case "define": return TokenType.DEFINE;
                case "namespace": return TokenType.NAMESPACE;
                case "use": return TokenType.USE;
                case "new": return TokenType.NEW;
                case "delete": return TokenType.DELETE;
                case "alias": return TokenType.ALIAS;
                case "ref": return TokenType.REF;
                case "const": return TokenType.CONST;
                case "as": return TokenType.AS;
                case "instanceof": return TokenType.INSTANCEOF;
                case "typeof": return TokenType.TYPEOF;
                case "sizeof": return TokenType.SIZEOF;
                default: return TokenType.IDENTIFIER;
        }
}

module lery::lexer::token::span;

struct TokenSpan {
        usz start;
        usz end;
}

fn TokenSpan new(usz start, usz len) => TokenSpan { .start = start, .end = start + len };
