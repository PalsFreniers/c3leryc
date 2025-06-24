module lery::utils;
import libc;
import std::io;
import lery::lexer;

macro todo($msg, args...) @noreturn {
        io::print("TODO: ");
        io::printfn($msg, args);
        libc::exit(1);
}

macro warning(loc, $msg, args...) {
        io::printf("[WARNING] %s:%d:%d => ", loc.file, loc.line, loc.column);
        io::printfn($msg, args);

}

module lery::utils::result(<Ok, Err>);

fault ResultFault {
        ERROR,
        NO_ERROR,
}

struct Result {
        Ok ok;
        Err err;
        bool isOk;
}

fn Ok! Result.getOk(&self) {
        if(self.isOk) return self.ok;
        return ResultFault.ERROR?;
}

fn Err! Result.getError(&self) {
        if(!self.isOk) return self.err;
        return ResultFault.NO_ERROR?;
}

macro Result _ok(Ok val) => Result {
        .ok = val,
        .isOk = true,
};

macro Result _err(Err val) => Result {
        .err = val,
        .isOk = false,
};

