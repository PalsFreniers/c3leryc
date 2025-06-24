module lery::checker;
import lery::parser;
import lery::utils;
import lery::lexer::token;

fn CheckedProgram! Checker.check(&self) {
        CheckedProgram cProg;
        cProg.new_init();
        foreach(n: self.prog) {
                cProg.push(self.checkGlobal(n)!);
        }
        return cProg;
}

fn CheckedGlobal! Checker.checkGlobal(&self, ASTNode node) {
        switch(node.kind) {
                default:
                        unreachable("checker globals");
        }
}

fn CheckedStatement! Checker.checkStatement(&self, StatementASTNode node) {
        switch(node.kind) {
                default:
                        unreachable("checker statements");
        }
}

macro checkedBaseExpression(CheckedExpression* ok, TokenSpan errSpan, TypeId hint, TypeId resId) {
        if(!type::isCorrect(hint)) return res::ok(ok);
        if(type::isNot(hint, resId)) return res::err(CheckedExpression*, type::newTypeMismatch(errSpan, hint, resId));
        return res::ok(ok);
}

fn CheckedResult(<CheckedExpression*>) Checker.checkExpression(&self, ExpressionASTNode* node, TypeId hint) {
        switch(node.kind) {
                case ExpressionKind.UNIT:
                        return checkedBaseExpression(
                                st::newCheckedUnit(node.as.unit),
                                node.as.unit,
                                hint,
                                type::VOID_ID
                        );
                case ExpressionKind.BOOL_LITERAL:
                        return checkedBaseExpression(
                                st::newCheckedBool(node.as.boolLit),
                                node.as.boolLit.span,
                                hint,
                                type::BOOL_ID
                        );
                case ExpressionKind.INT_LITERAL:
                        if(!type::isValidInt(hint)) return res::err(CheckedExpression*, type::newTypeMismatch(node.as.intLit.span, hint, type::BUILTIN_INT_ID));
                        return res::ok(st::newCheckedInt(node.as.intLit, hint));
                case ExpressionKind.IDENTIFIER:
                        TypeId id = self.getVar(node.as.ident.as.ident);
                        if(type::isValidInt(id) && type::isValidInt(hint)) return res::ok(st::newCheckedIdentInt(node.as.ident, id, hint));
                        return checkedBaseExpression(
                                st::newCheckedIdent(node.as.ident, hint),
                                node.as.ident.span,
                                hint,
                                id
                        );
                case ExpressionKind.BINARY:
                        CheckedResult(<CheckedExpression*>) lhs = self.checkExpression(node.as.binop.lhs, hint);
                        if(try lhs.getError()) return lhs;
                        CheckedResult(<CheckedExpression*>) rhs = self.checkExpression(node.as.binop.rhs, hint);
                        if(try rhs.getError()) return rhs;
                        // TODO: overload
                        TypeId id;
                        switch(self.as.binop.op.type) {
                                case TokenType.PLUS:
                                        if(type::isValidInt(lhs.getOk().type) && type::isValidInt(rhs.getOk().type)) {
                                                id = self.promoteIntSize(lhs.getOk().type, rhs.getOk().type);
                                                if(id == type::ERROR) return res::err(CheckedExpression*, type::new)
                                        }
                                        return res::ok(st::newCheckedBinop(CheckedBinopType.PLUS, lhs, rhs));
                                default:
                                        unreachable("check binop");
                        }
                default:
                        unreachable("checker expression");
        }
}
