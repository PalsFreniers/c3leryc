# Lery Programming Language

Lery is a multipurpose, compiled, and system programming language designed to be verbose, strict, and highly configurable. It aims to be easy to learn while capable of creating complex applications.

## Features

- **Explicit and Verbose**: Minimal type inference, requiring explicit type declarations
- **Multiple Paradigms**: Supports imperative, object-oriented, and functional programming styles
- **Strict Typing**: Strong static typing with no confusing features like function overloading
- **Highly Configurable**: Custom backends and ABI interoperability with other languages
- **Rich Feature Set**: Classes, structs, unions, bitstructs, bitunions, namespaces, enums, and more

## Language Constructs

### Scopes
- `{}` - Blocks: Symbols (functions, variables, etc.) are not accessible in parent scopes
- `fn` - Functions: Symbols are not accessible in parent scopes
- `ns` - Namespaces: Symbols are accessible in parent scopes via namespace access
- `cl` - Classes
- `ty` - Types
- `en` - Enumerations
- `un` - Unions
- `bs` - Bitstructs
- `bu` - Bitunions

### Keywords
Lery includes extensive keywords for:
- Control flow: `if`, `elif`, `else`, `while`, `for`, `do`, `break`, `continue`
- Exception handling: `try`, `catch`, `finally`, `throw`
- Object-oriented programming: `class`, `method`, `property`, `static`, `get`, `set`, `operator`, `cast`, `implements`, `extends`, `interface`
- Data structures: `enum`, `struct`, `bitstruct`, `union`, `bitunion`, `type`, `bit`
- Memory management: `new`, `delete`, `ref`, `alias`
- Type operations: `typeof`, `instanceof`, `sizeof`
- Constants and literals: `true`, `false`, `const`
- Operators: Arithmetic, bitwise, logical, comparison, and assignment operators

## Building

The project includes a pre-built executable in the `build/` directory:

```bash
# To use the built compiler
./build/lery [options] <source_file>
```

## Usage

The Lery compiler supports several modes:

```bash
# Basic compilation
./build/lery <source_file.lery>

# Lexer only (show tokens)
./build/lery lex <source_file.lery>

# AST only (show abstract syntax tree)
./build/lery ast <source_file.lery>
```

## Example

Here's a simple Lery program (`test_lery/1.lery`):

```lery
global x: u32 = 15;

fn entry() -> u32 {
        y: u32 = 15;
        x += 2;
        x =- 2;
        y = x;
        return y;
}
```

## Project Structure

- `src/` - Source code
  - `main.c3` - Compiler entry point
  - `lexer/` - Lexical analysis components
  - `parser/` - Syntax analysis components
  - `checker/` - Semantic analysis components
  - `IR/` - Intermediate representation
  - `utils.c3` - Utility functions
- `build/` - Built executable and LLVM intermediate files
- `test_lery/` - Test Lery source files

## Implementation Details

The Lery compiler is implemented in C3 and follows a traditional compiler architecture:
1. **Lexer** (`lexer/`) - Converts source code to tokens
2. **Parser** (`parser/`) - Builds AST from tokens
3. **Checker** (`checker/`) - Performs semantic analysis
4. **Code Generation** - LLVM-based backend (in `build/llvm/`)

## Requirements

- C3 compiler for building from source
- LLVM for code generation (for the built executable)

## Language Goals

As stated in the original README:
- Be as verbose as possible
- Refuse major type inference
- Be as personal as possible
- Support multiple programming paradigms
- Be a multipurpose, compiled, and system language
- Refuse confusing features (e.g., function overload)
- Be as strict as possible (e.g., static typing)
- Be as configurable as possible (e.g., custom backend)
- Be interoperable with other language's ABI
- Be easy to learn yet able to create complex/complete applications