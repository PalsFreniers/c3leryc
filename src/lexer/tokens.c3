module lery::lexer::token;

enum TokenType {
        // KEYWORDS
        GLOBAL,             // [ ] global
        FUNCTION,           // [ ] fn
        RETURN,             // [ ] return
        IF,                 // [ ] if
        ELIF,               // [ ] elif
        ELSE,               // [ ] else
        WHILE,              // [ ] while
        FOR,                // [ ] for
        BREAK,              // [ ] break
        CONTINUE,           // [ ] continue
        DO,                 // [ ] do
        TRY,                // [ ] try
        CATCH,              // [ ] catch
        FINALLY,            // [ ] finally
        THROW,              // [ ] throw
        SWITCH,             // [ ] switch
        CASE,               // [ ] case
        DEFAULT,            // [ ] default
        IMPORT,             // [ ] import
        MODULE,             // [ ] module
        CLASS,              // [ ] class
        METHOD,             // [ ] method
        STATIC,             // [ ] static
        GET,                // [ ] get
        SET,                // [ ] set
        OPERATOR,           // [ ] operator
        CAST,               // [ ] cast
        IMPLEMENTS,         // [ ] implements
        EXTENDS,            // [ ] extends
        INTERFACE,          // [ ] interface
        ENUM,               // [ ] enum
        STRUCT,             // [ ] struct
        BITSTRUCT,          // [ ] bitstruct
        UNION,              // [ ] union
        BITUNION,           // [ ] bitunion
        TYPE,               // [ ] type
        BITS,               // [ ] bit
        DEFINE,             // [ ] define
        NAMESPACE,          // [ ] namespace
        USE,                // [ ] use
        NEW,                // [ ] new
        DELETE,             // [ ] delete
        ALIAS,              // [ ] alias
        AS,                 // [ ] as
        INSTANCEOF,         // [ ] instanceof
        TYPEOF,             // [ ] typeof
        SIZEOF,             // [ ] sizeof
        // GLOBAL SYNTAX 
        ASSIGNMENT,         // [x] =
        COLON,              // [x] :
        SEMICOLON,          // [x] ;
        COMMA,              // [x] ,
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
        ASSIGN_NXOR,        // [x] =~^ / [x] =~^
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
        INT_LITERAL,
        // ELSE
        IDENTIFIER,
        END_OF_FILE,
}

union TokenValue {
        int intLit;
}

struct Token {
        TokenType type;
        LexerLoc loc;
        TokenSpan span;
        TokenValue as;
}

fn Token new(TokenType type, LexerLoc loc = {}, TokenSpan span = {}, TokenValue as = {}) => Token { .type = type, .loc = loc, .span = span, .as = as };

module lery::lexer::token::span;

struct TokenSpan {
        usz start;
        usz end;
}

fn TokenSpan new(usz start, usz len) => TokenSpan { .start = start, .end = start + len };
