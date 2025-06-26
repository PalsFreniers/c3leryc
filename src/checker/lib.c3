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
                case ASTKind.GLOBAL_DECL:
                        String name = node.as.globalDecl.name;
                        TypeId type = self.getTypeFromAST();
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

fn CheckedResult(<CheckedExpression*>) Checker.checkExpression(&self, ExpressionASTNode* node) {
        switch(node.kind) {
                default:
                        unreachable("checker expression");
        }
}
