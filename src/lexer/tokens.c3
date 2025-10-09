module lery::lexer::token;
import lery::lexer;
import lery::parser;
import std::io;

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
        TRUE,               // [x] true
        FALSE,              // [x] false
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
        INT_LITERAL,        // [x] (0[xb])?[0-9][0-9a-fA-F_]*
        // ELSE
        IDENTIFIER,         // [x] [_a-zA-Z][_0-9a-zA-Z]*
        END_OF_FILE,        // [x]
}

fn void Token.show(&self) {
        switch(self.type) {
                case TokenType.GLOBAL:
                        io::printfn("GLOBAL");
                case TokenType.FUNCTION:
                        io::printfn("FUNCTION");
                case TokenType.RETURN:
                        io::printfn("RETURN");
                case TokenType.IF:
                        io::printfn("IF");
                case TokenType.ELIF:
                        io::printfn("ELIF");
                case TokenType.ELSE:
                        io::printfn("ELSE");
                case TokenType.WHILE:
                        io::printfn("WHILE");
                case TokenType.FOR:
                        io::printfn("FOR");
                case TokenType.BREAK:
                        io::printfn("BREAK");
                case TokenType.CONTINUE:
                        io::printfn("CONTINUE");
                case TokenType.DO:
                        io::printfn("DO");
                case TokenType.TRY:
                        io::printfn("TRY");
                case TokenType.CATCH:
                        io::printfn("CATCH");
                case TokenType.FINALLY:
                        io::printfn("FINALLY");
                case TokenType.THROW:
                        io::printfn("THROW");
                case TokenType.SWITCH:
                        io::printfn("SWITCH");
                case TokenType.CASE:
                        io::printfn("CASE");
                case TokenType.DEFAULT:
                        io::printfn("DEFAULT");
                case TokenType.IMPORT:
                        io::printfn("IMPORT");
                case TokenType.MODULE:
                        io::printfn("MODULE");
                case TokenType.CLASS:
                        io::printfn("CLASS");
                case TokenType.METHOD:
                        io::printfn("METHOD");
                case TokenType.PROPERTY:
                        io::printfn("PROPERTY");
                case TokenType.STATIC:
                        io::printfn("STATIC");
                case TokenType.GET:
                        io::printfn("GET");
                case TokenType.SET:
                        io::printfn("SET");
                case TokenType.OPERATOR:
                        io::printfn("OPERATOR");
                case TokenType.CAST:
                        io::printfn("CAST");
                case TokenType.IMPLEMENTS:
                        io::printfn("IMPLEMENTS");
                case TokenType.EXTENDS:
                        io::printfn("EXTENDS");
                case TokenType.INTERFACE:
                        io::printfn("INTERFACE");
                case TokenType.ENUM:
                        io::printfn("ENUM");
                case TokenType.STRUCT:
                        io::printfn("STRUCT");
                case TokenType.BITSTRUCT:
                        io::printfn("BITSTRUCT");
                case TokenType.UNION:
                        io::printfn("UNION");
                case TokenType.BITUNION:
                        io::printfn("BITUNION");
                case TokenType.TYPE:
                        io::printfn("TYPE");
                case TokenType.BITS:
                        io::printfn("BITS");
                case TokenType.DEFINE:
                        io::printfn("DEFINE");
                case TokenType.NAMESPACE:
                        io::printfn("NAMESPACE");
                case TokenType.USE:
                        io::printfn("USE");
                case TokenType.NEW:
                        io::printfn("NEW");
                case TokenType.DELETE:
                        io::printfn("DELETE");
                case TokenType.ALIAS:
                        io::printfn("ALIAS");
                case TokenType.REF:
                        io::printfn("REF");
                case TokenType.CONST:
                        io::printfn("CONST");
                case TokenType.AS:
                        io::printfn("AS");
                case TokenType.INSTANCEOF:
                        io::printfn("INSTANCEOF");
                case TokenType.TYPEOF:
                        io::printfn("TYPEOF");
                case TokenType.TRUE:
                        io::printfn("TRUE");
                case TokenType.FALSE:
                        io::printfn("FALSE");
                case TokenType.SIZEOF:
                        io::printfn("SIZEOF");
                case TokenType.ASSIGNMENT:
                        io::printfn("ASSIGNMENT");
                case TokenType.COLON:
                        io::printfn("COLON");
                case TokenType.SEMICOLON:
                        io::printfn("SEMICOLON");
                case TokenType.COMMA:
                        io::printfn("COMMA");
                case TokenType.DOT:
                        io::printfn("DOT");
                case TokenType.RIGHT_ARROW:
                        io::printfn("RIGHT_ARROW");
                case TokenType.LEFT_PAREN:
                        io::printfn("LEFT_PAREN");
                case TokenType.RIGHT_PAREN:
                        io::printfn("RIGHT_PAREN");
                case TokenType.LEFT_BRACKET:
                        io::printfn("LEFT_BRACKET");
                case TokenType.RIGHT_BRACKET:
                        io::printfn("RIGHT_BRACKET");
                case TokenType.LEFT_BRACE:
                        io::printfn("LEFT_BRACE");
                case TokenType.RIGHT_BRACE:
                        io::printfn("RIGHT_BRACE");
                case TokenType.PLUS:
                        io::printfn("PLUS");
                case TokenType.PLUS_ASSIGN:
                        io::printfn("PLUS_ASSIGN");
                case TokenType.ASSIGN_PLUS:
                        io::printfn("ASSIGN_PLUS");
                case TokenType.MINUS:
                        io::printfn("MINUS");
                case TokenType.MINUS_ASSIGN:
                        io::printfn("MINUS_ASSIGN");
                case TokenType.ASSIGN_MINUS:
                        io::printfn("ASSIGN_MINUS");
                case TokenType.STAR:
                        io::printfn("STAR");
                case TokenType.STAR_ASSIGN:
                        io::printfn("STAR_ASSIGN");
                case TokenType.ASSIGN_STAR:
                        io::printfn("ASSIGN_STAR");
                case TokenType.SLASH:
                        io::printfn("SLASH");
                case TokenType.SLASH_ASSIGN:
                        io::printfn("SLASH_ASSIGN");
                case TokenType.ASSIGN_SLASH:
                        io::printfn("ASSIGN_SLASH");
                case TokenType.MODULUS:
                        io::printfn("MODULUS");
                case TokenType.MODULUS_ASSIGN:
                        io::printfn("MODULUS_ASSIGN");
                case TokenType.ASSIGN_MODULUS:
                        io::printfn("ASSIGN_MODULUS");
                case TokenType.EXPONENT:
                        io::printfn("EXPONENT");
                case TokenType.EXPONENT_ASSIGN:
                        io::printfn("EXPONENT_ASSIGN");
                case TokenType.ASSIGN_EXPONENT:
                        io::printfn("ASSIGN_EXPONENT");
                case TokenType.INCREMENT:
                        io::printfn("INCREMENT");
                case TokenType.DECREMENT:
                        io::printfn("DECREMENT");
                case TokenType.OR:
                        io::printfn("OR");
                case TokenType.OR_ASSIGN:
                        io::printfn("OR_ASSIGN");
                case TokenType.ASSIGN_OR:
                        io::printfn("ASSIGN_OR");
                case TokenType.AND:
                        io::printfn("AND");
                case TokenType.AND_ASSIGN:
                        io::printfn("AND_ASSIGN");
                case TokenType.ASSIGN_AND:
                        io::printfn("ASSIGN_AND");
                case TokenType.XOR:
                        io::printfn("XOR");
                case TokenType.XOR_ASSIGN:
                        io::printfn("XOR_ASSIGN");
                case TokenType.ASSIGN_XOR:
                        io::printfn("ASSIGN_XOR");
                case TokenType.NOT:
                        io::printfn("NOT");
                case TokenType.NOTCREMENT:
                        io::printfn("NOTCREMENT");
                case TokenType.NOR:
                        io::printfn("NOR");
                case TokenType.NOR_ASSIGN:
                        io::printfn("NOR_ASSIGN");
                case TokenType.ASSIGN_NOR:
                        io::printfn("ASSIGN_NOR");
                case TokenType.NAND:
                        io::printfn("NAND");
                case TokenType.NAND_ASSIGN:
                        io::printfn("NAND_ASSIGN");
                case TokenType.ASSIGN_NAND:
                        io::printfn("ASSIGN_NAND");
                case TokenType.NXOR:
                        io::printfn("NXOR");
                case TokenType.NXOR_ASSIGN:
                        io::printfn("NXOR_ASSIGN");
                case TokenType.ASSIGN_NXOR:
                        io::printfn("ASSIGN_NXOR");
                case TokenType.SHIFT_LEFT:
                        io::printfn("SHIFT_LEFT");
                case TokenType.SHIFT_LEFT_ASSIGN:
                        io::printfn("SHIFT_LEFT_ASSIGN");
                case TokenType.ASSIGN_SHIFT_LEFT:
                        io::printfn("ASSIGN_SHIFT_LEFT");
                case TokenType.SHIFT_RIGHT:
                        io::printfn("SHIFT_RIGHT");
                case TokenType.SHIFT_RIGHT_ASSIGN:
                        io::printfn("SHIFT_RIGHT_ASSIGN");
                case TokenType.ASSIGN_SHIFT_RIGHT:
                        io::printfn("ASSIGN_SHIFT_RIGHT");
                case TokenType.BOOL_NOT:
                        io::printfn("BOOL_NOT");
                case TokenType.BOOL_OR:
                        io::printfn("BOOL_OR");
                case TokenType.BOOL_AND:
                        io::printfn("BOOL_AND");
                case TokenType.EQUAL:
                        io::printfn("EQUAL");
                case TokenType.NOT_EQUAL:
                        io::printfn("NOT_EQUAL");
                case TokenType.LESS_THAN:
                        io::printfn("LESS_THAN");
                case TokenType.GREATER_THAN:
                        io::printfn("GREATER_THAN");
                case TokenType.LESS_EQUAL:
                        io::printfn("LESS_EQUAL");
                case TokenType.GREATER_EQUAL:
                        io::printfn("GREATER_EQUAL");
                case TokenType.INT_LITERAL:
                        io::printfn("INT_LITERAL(%d)", self.as.intLit);
                case TokenType.IDENTIFIER:
                        io::printfn("IDENTIFIER(%s)", self.as.ident);
                case TokenType.END_OF_FILE:
                        io::printfn("END_OF_FILE");
                default: unreachable("unreachable token show");
        }
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

fn Token new(TokenType type, LexerLoc loc = {}, TokenSpan span = {}, TokenValue as = {}) => Token {
	type = type,
	loc = loc,
	span = span,
	as = as
};

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
                case "true": return TokenType.TRUE;
                case "false": return TokenType.FALSE;
                default: return TokenType.IDENTIFIER;
        }
}

fn void? Token.checkTypeIdent(&self, Parser* parser) {
        if(self.type != TokenType.IDENTIFIER) return parser.error(*self, "unreachable")? ?? LexerFault.INVALID_IDENT?;
        switch(self.toString(parser.src)) {
                case "void": nextcase;
                case "u8": nextcase;
                case "u16": nextcase;
                case "u32": nextcase;
                case "u64": nextcase;
                case "i8": nextcase;
                case "i16": nextcase;
                case "i32": nextcase;
                case "i64": nextcase;
                case "bool": return parser.error(*self, "builtin typenames cannot be used as identifier")? ?? LexerFault.RESERVED_IDENT?;
                default: return;
        }
}

module lery::lexer::token::span;

struct TokenSpan {
        usz start;
        usz end;
}

fn TokenSpan new(usz start, usz len) => TokenSpan {
	start = start,
	end = start + len
};
