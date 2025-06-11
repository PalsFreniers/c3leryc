module lery::ir::tree;
import lery::ir::type;

interface IRNode {
        fn IRType! processType();
}

struct IRNodeAdd(IRNode) {
        IRType type;
        IRNode left;
        IRNode right;
}

module lery::ir::type;

interface IRType {
        fn IRTypeKind getKind();
}

macro IRType.to(self, $Type) => ($Type)self;

enum IRTypeKind {
        INTEGER,
}

struct IRIntegerType(IRType) {
        int size;
        bool signed;
}

fn IRTypeKind IRIntegerType.getKind(&self) @dynamic {
        return IRTypeKind.INTEGER;
}
