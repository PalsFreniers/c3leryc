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
        List{ Scope } scopes;
        List{ CTypeData } types;
        List{ TypeError } errors;
}

macro Checker.newType(&self, name, size, scopeId) => self.types.push(type::new(name, size, scopeId));

fn Checker new(Program prog, String src) {
        Checker check = Checker {
                prog = prog,
                src = src,
        };
        check.currScope = scope::GLOBAL;
        check.scopes.new_init();
        check.types.new_init();
        check.errors.new_init();
        check.allocScope(scope::ERROR);
        check.newType("void",        0, scope::GLOBAL);
        check.newType("u32",         4, scope::GLOBAL);
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

alias CheckedProgram = List{ CheckedGlobal };

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

macro newCheckedGlobal(type, kind, data) => CheckedGlobal {
        typeId = type,
        kind = kind,
        as = data,
};

struct CheckedGlobalDecl {
        String name;
        CheckedExpression* val;
}

macro newCheckedGlobalDecl(type, name, expr) => newCheckedGlobal(type, CheckedGlobalKind.GLOBAL_DECL, CheckedGlobalData {
        globalDecl = CheckedGlobalDecl {
                name = name,
                val = expr,
        }
});

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

module lery::checker::scope;
import lery::checker::type;
import std::collections::map;

alias ScopeId = isz;

struct Scope {
        ScopeId parentId;
        Map{ String, TypeId } vars;
}

enum Symbol {
        VAR,
}

macro Scope.newVar(&self, String name, TypeId type) => self.vars[name] = type;

macro Scope.getSymbolType(&self, Symbol $type, name) {
        $switch($type):
                $case Symbol.VAR:
                        return self.vars[name];
        $endswitch
}

macro TypeId? Scope.getVar(&self, String name) => self.getSymbolType(Symbol.VAR, name);

macro Scope new(ScopeId parentId) => Scope {
        parentId = parentId,
};

const GLOBAL = 0;
const ERROR = -1;
const NONE = -2;

module lery::checker::type;
import lery::checker::scope;
import lery::lexer::token::span;

alias TypeId = isz;

struct CTypeData {
        String name;
        usz byteSize;
        ScopeId scopeId;
}

macro new(name, size, scopeId) => CTypeData {name, size, scopeId};

macro isCorrect(hint) => hint != ERROR;

macro isNot(hint, type) => (!isCorrect(hint)) || type != hint;

macro isValidInt(hint) => (!isCorrect(hint)) && (hint >= BUILTIN_INT_ID && hint <= I64_ID);

macro isSignedInt(hint) => isValidInt(hint) && (hint >= I8_ID);


struct TypeError {
        TokenSpan span;
        String msg;
        TypeId expected;
        TypeId got;
}

macro newTypeError(span, expected, got, msg = "") => TypeError {
        span = span,
        msg = msg,
        expected = expected,
        got = got,
};

macro newTypeMismatch(span, expected, got, $msg = "") => newTypeError(span, expected, got, "Mismatch type expected & but got &" +++ $msg);

module lery::checker::result{ Ok }; 
import lery::checker::type;
import lery::utils::result;

alias CheckedResult = Result{ Ok, TypeError };

module lery::checker::result::res;
import lery::checker::result;
import lery::checker::type;
import lery::utils::result;

macro ok(val) => result::_ok{ $typeof(val), TypeError }(val);

macro err($Type, TypeError val) => result::_err{ $Type, TypeError }(val);
