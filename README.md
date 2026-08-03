# B Compiler - A B Language Compiler

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Made with Flex](https://img.shields.io/badge/Made%20with-Flex-blue.svg)](https://github.com/westes/flex)
[![Made with Bison](https://img.shields.io/badge/Made%20with-Bison-purple.svg)](https://www.gnu.org/software/bison/)

A compiler for the B programming language, implemented using **Flex** (lexical analyzer) and **Bison** (parser). This project translates B source code into i386 GNU assembly language.

## 📋 Table of Contents

- [About B](#about-b)
- [Features](#features)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Building the Compiler](#building-the-compiler)
- [Debug Mode](#debug-mode)
- [How It Works](#how-it-works)
- [Limitations](#limitations)
- [Future Improvements](#future-improvements)
- [Contributing](#contributing)
- [License](#license)

---

## 📖 About B

**B** is a programming language created by **Ken Thompson** at Bell Labs in 1969. It was designed for the PDP-7 and later the PDP-11 minicomputers. B is the direct predecessor of the C programming language, sharing many syntactic and semantic similarities.

### Key Characteristics of B:
- **Typeless** - All variables are machine words (no `int`, `char`, etc.)
- **Interpreted/Compiled** - Original B was interpreted, but this is a compiler
- **C-like syntax** - Serves as the foundation for C language
- **Minimalistic** - Simple but powerful language

### Why B?
This project was developed as part of the **42 School** curriculum to understand:
- How compilers work internally
- Lexical analysis with Flex
- Syntax analysis with Bison
- Code generation for x86 architecture
- Syntax-directed translation

---

## ✨ Features

### Current Features
- ✅ Lexical analysis with Flex
- ✅ Full B grammar with Bison
- ✅ Variable declarations (`auto`)
- ✅ External declarations (`extrn`)
- ✅ Functions with parameters
- ✅ Arithmetic operations (`+`, `-`, `*`, `/`)
- ✅ Relational operators (`<`, `>`, `<=`, `>=`, `==`, `!=`)
- ✅ Logical operators (`&&`, `||`, `!`)
- ✅ Control flow (`if`/`else`, `while`)
- ✅ Increment/Decrement (`++`, `--`)
- ✅ Function calls with arguments
- ✅ Array declarations and access
- ✅ i386 Assembly code generation
- ✅ Debug mode with `-DDEBUG`
- ✅ Memory-safe (proper `free()` calls)

### Planned Features
- [ ] Full B standard library
- [ ] Floating-point support
- [ ] Switch/case statements
- [ ] Labels and `goto`
- [ ] Optimizations

---

## 📁 Project Structure
b-compiler/
├── Makefile # Build system with debug mode
├── README.md # This file
├── src/
│ ├── lex/
│ │ └── b.l # Flex lexical analyzer
│ └── yacc/
│ └── b.y # Bison grammar parser
├── .gen/ # Generated C files (build-time)
│ ├── lex.yy.c
│ ├── y.tab.c
│ └── y.tab.h
├── .obj/ # Object files (build-time)
│ ├── lex.yy.o
│ └── y.tab.o
├── tests/ # Test B programs
│ ├── hello.b
│ ├── arithmetic.b
│ └── loops.b
└── examples/ # Example B programs
├── factorial.b
└── fibonacci.b


---

## 🛠️ Requirements

- **Flex** (lexical analyzer generator)
- **Bison** (parser generator)
- **GCC** (C compiler)
- **GNU Make** (build automation)
- **i386 architecture support** (32-bit)

### Installing Dependencies

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install flex bison gcc make
```
#### macOS (with Homebrew):

```
brew install flex bison gcc make
```

#### Arch Linux:
```
sudo pacman -S flex bison gcc make
```

### 📦 Installation
**1. Clone the repository**
```bash
git clone git@github.com:dacortes/B.git
cd B
```
**2. Build the compiler**
```bash
make
```

### Basic Usage
```bash
./B < input.b > output.s
```

### Where:

    input.b is your B source code

    output.s is the generated assembly code


### 💻 Examples
Hello World Program

File: hello.b
```c
extrn putchar;
extrn char;

main() {
    auto i;
    auto s;

    i = 0;
    s = "hello, world\n";

    while (char(s, i)) {
        putchar(char(s, i));
        i = i + 1;
    }
}
```

