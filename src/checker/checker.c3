module lery::checker::st;
import lery::parser;
import lery::checker::scope;
import lery::checker::type;
import std::collections::list;
import lery::lexer::token::span;
import lery::utils;

struct Checker {
        Program prog;
        String src;
        ScopeId currScope;
        List(<Scope>) scopes;
        List(<CTypeData>) types;
        List(<TypeError>) errors;
}

macro Checker.newType(&self, name, size, scopeId) => self.types.push(type::new(name, size, scopeId));

fn Checker new(Program prog, String src) {
        Checker check = Checker {
                .prog = prog,
                .src = src,
        };
        check.currScope = scope::GLOBAL;
        check.scopes.new_init();
        check.types.new_init();
        check.errors.new_init();
        check.allocScope(scope::ERROR);
        check.newType("void",        0, scope::GLOBAL);
        check.newType("builtin.int", 0, scope::GLOBAL);
        check.newType("u8",          1, scope::GLOBAL);
        check.newType("u16",         2, scope::GLOBAL);
        check.newType("u32",         4, scope::GLOBAL);
        check.newType("u64",         8, scope::GLOBAL);
        check.newType("i8",          1, scope::GLOBAL);
        check.newType("i16",         2, scope::GLOBAL);
        check.newType("i32",         4, scope::GLOBAL);
        check.newType("i64",         8, scope::GLOBAL);
        check.newType("bool",        1, scope::GLOBAL);
        return check;
}

macro Checker.getVar(&self, String name, ScopeId id = scope::NONE) {
        if(id == scope::NONE) id = self.currScope;
        if(id == scope::ERROR) return type::ERROR;
        if(try valType = self.scopes[id].getVar(name)) return valType;
        return self.getVar(name, self.scopes[self.currScope].parentId);
}

macro Checker.getTypeSize(&self, TypeId type) {
        return self.types[type].byteSize;
}

macro TypeId Checker.promoteIntSize(&self, a, b) {
        bool aSign = isSignedInt(a);
        bool bSign = isSignedInt(b);
        int aSize = self.getTypeSize(a);
        int bSize = self.getTypeSize(b);

        if(aSign && bSign) return aSize > bSize ? a : b;

        if(!aSign && aSize >= bSize) return a;
        if(!bSign && bSize >= aSize) return b;

        return type::ERROR;
}

fn bool Checker.scopeContains(&self, ScopeId container, ScopeId contained) {
        if(contained == container) return true;
        ScopeId parent = self.scopes[contained].parentId;
        while(parent != -1 && container != parent) {
                parent = self.scopes[parent].parentId;
        }
        if(parent == -1) return false;
        return true;
}

fn TypeId Checker.lookupType(&self, String name, ScopeId scopeId) {
        foreach(i, t: self.types) if(name == t.name && self.scopeContains(t.scopeId, scopeId)) return i;
        return -1;
}

macro ScopeId Checker.allocScope(&self, ScopeId parentId) {
        self.scopes.push(scope::new(parentId));
        return self.scopes.len() - 1;
}

def CheckedProgram = List(<CheckedGlobal>);

enum CheckedGlobalKind {
        GLOBAL_DECL,
}

union CheckedGlobalData {
        CheckedGlobalDecl globalDecl;
}

struct CheckedGlobal {
        TypeId typeId;
        CheckedGlobalKind kind;
        CheckedGlobalData as;
}

struct CheckedGlobalDecl {
        String name;
        CheckedExpression* val;
}

enum CheckedStatementKind {
        RETURN,
}

union CheckedStatementData {
        CheckedReturnStatement ret;
}

struct CheckedStatement {
        TypeId typeId;
        CheckedStatementKind kind;
        CheckedStatementData as;
}

struct CheckedReturnStatement {
        CheckedExpression* expr;
}

enum CheckedExpressionKind {
        UNIT,
        INT_LITERAL,
        BOOL_LITERAL,
        IDENT,
        BINOP,
}

union CheckedExpressionData {
        usz intLit;
        bool boolLit;
        String ident;
        CheckedBinop binop;
}

struct CheckedExpression {
        CheckedExpressionKind kind;
        CheckedExpressionData as;
        TokenSpan span;
        TypeId typeId;
}

enum CheckedBinopType {
        PLUS,
}

struct CheckedBinop {
        CheckedBinopType kind;
        CheckedExpression* lhs;
        CheckedExpression* rhs;
}

macro newCheckedBinop(kind, lhs, rhs, kind) =>

macro newCheckedExpression(kind, data, span, typeId) => mem::new(CheckedExpression, {
        .kind = kind,
        .as = data,
        .span = span,
        .typeId = typeId,
});

macro newCheckedUnit(span) => newCheckedExpression(CheckedExpressionKind.UNIT, CheckedExpressionData {}, span, type::VOID_ID);

macro newCheckedBool(Token val) => newCheckedExpression(CheckedExpressionKind.BOOL_LITERAL, CheckedExpressionData {
        .boolLit = (val.type == TokenType.TRUE ? true : false),
}, val.span, type::BOOL_ID);

macro CheckedExpression.convertIntChecked(&self, TypeId hint, loc) {
        TypeId type = hint;
        usz data = self.as.intLit;
        usz tmp = data;
        switch(hint) {
                case type::NONE:
                        type = type::BUILTIN_INT_ID;
                case type::U8_ID:
                        type = type::U8_ID;
                        data &= 0xff;
                case type::U16_ID:
                        type = type::U16_ID;
                        data &= 0xffff;
                case type::U32_ID:
                        type = type::U32_ID;
                        data &= 0xffffffff;
                case type::U64_ID:
                        type = type::U64_ID;
                case type::I8_ID:
                        type = type::I8_ID;
                        data &= 0x7f;
                case type::I16_ID:
                        type = type::I16_ID;
                        data &= 0x7fff;
                case type::I32_ID:
                        type = type::I32_ID;
                        data &= 0x7fffffff;
                case type::I64_ID:
                        type = type::I64_ID;
                default:
                        unreachable("not a valid int");
        }
        if(data != tmp) utils::warning(loc, "int data lost due to int compression");
        self.as.intLit = data;
        self.typeId = type;
        return self;
}

macro CheckedExpression* newCheckedInt(Token val, TypeId hint) {
        return newCheckedExpression(CheckedExpressionKind.INT_LITERAL, CheckedExpressionData {
                .intLit = val.as.intLit,
        }, val.span, type::BUILTIN_INT_ID).convertIntChecked(hint, val.loc);
}

macro newCheckedIdentIdent(Checker* check, Token val, TypeId hint, TypeId type) {
        if(check.getTypeSize(hint) < check.getTypeSize(type)) utils::warning(val.loc, "possible int data lost due to int convertion");
        return newCheckedExpression(CheckedExpression.IDENT, CheckedExpressionData {
                .ident = val.as.ident,
        }, val.span, hint);
}

module lery::checker::scope;
import lery::checker::type;
import std::collections::map;

def ScopeId = isz;

struct Scope {
        ScopeId parentId;
        Map(<String, TypeId>) vars;
}

enum Symbol {
        VAR,
}

macro Scope.newVar(&self, String name, TypeId type) => self.vars[name] = type;

macro Scope.getSymbolType(&self, Symbol $type, name) {
        $switch($type)
                $case Symbol.VAR:
                        return self.vars[name];
        $endswitch
}

macro TypeId! Scope.getVar(&self, String name) => self.getSymbolType(Symbol.VAR, name);

macro Scope new(ScopeId parentId) => Scope {
        .parentId = parentId,
};

const GLOBAL = 0;
const ERROR = -1;
const NONE = -2;

module lery::checker::type;
import lery::checker::scope;
import lery::lexer::token::span;

def TypeId = isz;

struct CTypeData {
        String name;
        usz byteSize;
        ScopeId scopeId;
}

const ERROR          = -2;
const NONE           = -1;
const VOID_ID        = 0 ;
const BUILTIN_INT_ID = 1 ;
const U8_ID          = 2 ;
const U16_ID         = 3 ;
const U32_ID         = 4 ;
const U64_ID         = 5 ;
const I8_ID          = 6 ;
const I16_ID         = 7 ;
const I32_ID         = 8 ;
const I64_ID         = 9 ;
const BOOL_ID        = 10;

macro new(name, size, scopeId) => CTypeData {name, size, scopeId};

macro isCorrect(hint) => hint != ERROR;

macro isNot(hint, type) => (!isCorrect(hint)) || type != hint;

macro isValidInt(hint) => (!isCorrect(hint)) && (hint >= U8_ID && hint <= I64_ID);

macro isSignedInt(hint) => isValidInt(hint) && (hint >= I8_ID);


struct TypeError {
        TokenSpan span;
        String msg;
        TypeId expected;
        TypeId got;
}

macro newTypeError(span, expected, got, msg = "") => TypeError {
        .span = span,
        .msg = msg,
        .expected = expected,
        .got = got,
};

macro newTypeMismatch(span, expected, got, $msg = "")
        => newTypeError(span, expected, got, "Mismatch type expected & but got &" +++ $msg);

module lery::checker::result(<Ok>); 
import lery::checker::type;
import lery::utils::result;

def CheckedResult = Result(<Ok, TypeError>);

module lery::checker::result::res;
import lery::checker::result;
import lery::checker::type;
import lery::utils::result;

macro ok(val) => result::_ok(<$typeof(val), TypeError>)(val);

macro err($Type, TypeError val) => result::_err(<$Type, TypeError>)(val);
