module lery::checker;
import lery::parser;

struct Checker {
        Program prog;
        String src;
}

fn Checker new(Program prog, String src) => (Checker) {
        prog = prog,
        src = src,
};
