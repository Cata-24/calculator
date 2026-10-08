# Arithmetic Expression Evaluator in Haskell

A purely functional arithmetic expression parser and evaluator written in Haskell. The system implements custom monadic parser combinators to parse arithmetic expressions with operator precedence, parentheses, and variable assignment environment tracking.

## Features

- **Arithmetic Operations**: Addition (`+`), subtraction (`-`), multiplication (`*`), integer division (`/`), and modulo (`%`).
- **Operator Precedence & Grouping**: Correct precedence handling (multiplicative operations evaluated before additive operations) and nested parentheses (`(...)`).
- **Variable Assignments**: Support for variable assignment (`x = 10`) and variable lookup in subsequent expressions.
- **Monadic Parsing**: Custom parser combinator engine (`Parsing.hs`) implemented from first principles.
- **Batch & Interactive Execution**: Evaluates expressions sequentially from standard input or piped file streams.

## Project Structure

```
.
├── Parsing.hs       # Functional monadic parser combinator library
├── calculator.hs    # Abstract Syntax Tree (AST), grammar rules, evaluator, and main loop
├── input1.txt       # Sample input: arithmetic operators and parentheses
├── input2.txt       # Sample input: sequential variable assignment and reuse
└── input3.txt       # Sample input: complex expressions with variable evaluation
```

## Formal Grammar

The parser implements the following context-free grammar:

```text
command  ::= variable '=' expr | expr
expr     ::= term exprCont
exprCont ::= '+' term exprCont | '-' term exprCont | ε
term     ::= factor termCont
termCont ::= '*' factor termCont | '/' factor termCont | '%' factor termCont | ε
factor   ::= natural | variable | '(' expr ')'
```

## Requirements

- GHC (Glasgow Haskell Compiler) 8.10 or newer

## Building the Project

Compile `calculator.hs` using GHC:

```bash
ghc calculator.hs -o calc
```

On Windows, GHC will produce `calc.exe`.

Optional clean up of build artifacts (`.hi` and `.o` files):

Linux / macOS / PowerShell:
```bash
rm *.hi *.o
```

Windows Command Prompt:
```cmd
del *.hi *.o
```

## Running the Calculator

### Batch Processing (Input Piping)

You can pass test input files directly into the compiled executable:

**Linux / macOS:**
```bash
./calc < input1.txt
# or
cat input2.txt | ./calc
```

**Windows PowerShell:**
```powershell
Get-Content input1.txt | .\calc.exe
```

**Windows Command Prompt:**
```cmd
calc.exe < input1.txt
```

### Interactive Execution

Run the binary directly to evaluate expressions interactively from standard input:

```bash
./calc
```

Input expressions line by line (press `Ctrl+D` on Unix or `Ctrl+Z` followed by `Enter` on Windows to exit):

```text
x = 5
x * 2 + 3
```

Output:
```text
5
13
```

### Interactive Exploration in GHCi

You can load the module into GHCi for testing parser output or evaluation directly:

```bash
ghci calculator.hs
```

Example interactive session:

```haskell
ghci> parse command "x=10+5"
[(Assign "x" (Add (Num 10) (Num 5)),"")]

ghci> eval [] (Add (Num 10) (Num 5))
15
```

## Behavior & Error Handling

- **Parse Failure**: Returns `parse error; try again` when an expression violates the grammar rules. The evaluation environment retains its previous variable bindings.
- **Undefined Variables**: Referencing a variable before assignment triggers an error (`undefined variable`).
