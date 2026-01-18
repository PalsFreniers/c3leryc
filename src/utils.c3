module lery::utils;
import libc;
import std::io;
import lery::lexer;

macro todo($msg, args...) @noreturn {
        io::print("TODO: ");
        io::printfn($msg, ...args);
        libc::exit(1);
}

macro warning(loc, $msg, args...) {
        io::printf("[WARNING] %s:%d:%d => ", loc.file, loc.line, loc.column);
        io::printfn($msg, ...args);
}
