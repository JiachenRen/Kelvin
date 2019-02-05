Kelvin CAS
=============
[![Build Status](https://travis-ci.com/JiachenRen/kelvin-cas.svg?branch=master)](https://travis-ci.com/JiachenRen/kelvin-cas)
![Swift 4.2](https://img.shields.io/badge/swift-4.2-orange.svg)
[![License: MIT](https://img.shields.io/apm/l/vim-mode.svg?colorB=blue&style=flat)](/LICENSE)

Kelvin is a powerful computer algebra system built with _Swift 4_. It is similar to its close relative, _Java Algebra System_, only a gazilion times faster & cleaner. Find [more](https://github.com/JiachenRen/java-algebra-system) about JAS here.

## Command Line
### Setup
1. Download the binary file `kelvin` from releases (or you can build it yourself with XCode)
2. If the file name is altered by your browser, remove the extension.
3. Optionally, you can add `kelvin` as part of your command line tools by the following command:
```bash
mv <path to kelvin> /usr/local/bin
```

### Usage
```bash
Usage: kelvin -c
   or  kelvin -e <expr>
   or  kelvin -f [options] <filepath>

Type kelvin without an option to enter interactive mode.

 where options include:

    -c format outputs with ANSI
    -e <expr> evaluate the expression that follows
    -f <filepath> execute the content of the file
    -v verbose
    -vc verbose output with ANSI
```

### Examples
- Type `kelvin` and hit return to enter interactive mode (lines starting with `←` denotes input).
```bash
# Enter interactive mode
$ kelvin

# Define a function f(x) that generates a fibonacci series up to the xth element
← def f(x) = ((x == 0 || x == 1 || x == 2) ? (1...x) : ((q := {1, 1}; repeat(q := (q ++ q[size q - 2] + q[size q - 1]), x - 2)); q))
→ def f(x) = x == 2 || x == 1 || x == 0 ? (1...x : q := {1, 1}; (q := (q ++ q::(size q - 2) + q::(size q - 1)))...x - 2; q)
= {1, 1}

# Generate the first 11 terms of the fibonacci series
← f(11)
→ f(11)
= {1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89}

# Exit Kelvin
← exit()
```
- If your terminal supports ANSI, use `kelvin -c` to activate ANSI coloring.
- Compile and run a file containing kelvin scripts.
```bash
# Change directory to tmp
$ cd /tmp

# Make a new file named "prg" containing a single line 'print "Hello World"'
$ echo "print \"Hello World\"" > prg

# Compile and run prg, which prints "Hello World"
$ kelvin -f /tmp/prg

# Alternatively, you can run the program with verbose on
$ kelvin -f -v /tmp/prg

# Program output under verbose mode
→ resolving absolute URL...
→ loading contents of prg
→ compiling...
→ compilation successful in 0.014269828796386719 seconds.
→ starting...
→ timestamp: 1549149227.4572248
→ begin program execution log:

      → print "Hello World"
      = "Hello World"

→ end program execution log.
→ program output:
Hello World
```
## The Kelvin Language
The Kelvin programming language is developed by a high school senior. Yes, really. It is a combination of `Javascript`, `Swift`, `Python`, and `Bash`, with a bunch of wierd syntatic sugars that came from my pure imagination. It is a interpreted language (nowhere near as fast), but it is powerful in terms of what it can do when it comes to solving high school math problems.
> As a side note, _Kelvin_ even has trailing closure syntax and anonymous arguments, a feature loved by Swift users!

### Examples
- Binary search algorithm written in `Kelvin`:
```swift
def bin_search(arr, search) {
    c := 0;
    first := 0;
    n := size(arr);
    last := n - 1;
    middle := int((first + last) / 2);

    while (first <= last) {
        b := false;

        if (arr[middle] < search) {
            first := middle + 1;
            b := true;
        }

        if (arr[middle] == search) {
            return middle;
        }

        if (!b) {
            last := middle - 1;
        }

        middle := int((first + last) / 2);
    }

    return "not found";
}

# Define a list l1
def l1 = {1, 2, 3, 5, 7, 8, 9, 10}
println bin_search(l1, 8.5)
assert bin_search(l1, 9) == 6
```
- For loops, if statements, while loops, etc. in `Kelvin`:
```swift
def foo(a, b) {
    while (a < 100 || b < 100) {
        println "a = " & a;
        a := a + 1;
        if (a > 50) {
            b++;
        }
        if (b % 3 == 0) {
            println b & " is a multiple of 3";
            for (i: map(0...10) {$1}) {
                print i
            }
            print "\n";
            continue;
        }
        println "b = " & b;
        if (b > 66) {
            break;
        }
    }

    return {a, b}
}

def result = foo(1, 3)
assert print(result) == {114, 67}
```

For more examples (algebraic operations, calulus, stats, loops, conditional statements, etc.), please refer to [Examples](Examples).

## Capabilities

### Arithmetic
- [x] Standard binary operations
  - *Addition*
  - *Subtraction*
  - *Multiplication*
  - *Division*
  - *Exponentiation*
- [x] Unary operations (many, see below)

### Number
- [x] Greatest common divisor & least common multiple
- [x] Prime factors
- [ ] Fraction
- [ ] Exact vs. approximate

### Algebra
- [x] Commutative simplification
- [x] Preliminary factorization
- [x] Expand expressions
- [ ] Complete the square
- [ ] Exponential simplification
- [ ] Solve
  - [ ] Numerical solve
  - [ ] Zeros
  - [ ] Algebraic solve

### Calculus
- [x] Differentiation
  - *Logarithmic differentiation*
  - *nth derivative*
  - *Multivariate (Calculus III)*
    - Partial derivatives
    - Implicit differentiation
    - Directional differentiation
    - Gradient
  
- [ ] Integration

### Statistics
- [x] One variable statistics
  - *Summation*
  - *Average*
  - *Sum of difference squared*
  - *Variance*
  - *Std. deviation*
  - *Five-number summary, IQR*
  - *Outliers*
  
- [ ] Two variable statistics
- [x] Distributions
  - [x] Normal Cdf (-∞ to x, from lb to ub, from lb to ub with μ and σ)
  - [x] Random normal distribution (randNorm)
  - [x] Normal Pdf
  - [x] Inverse Normal
  - [ ] Inverse t
  - [ ] Binomial Cdf/Pdf
  - [ ] Geometric Cdf/Pdf
- [ ] Confidence intervals
- [ ] Regression
  - [ ] Linear
  - [ ] Quadratic, cubic, quartic, power
  - [ ] Exponential/logarithmic
  - [ ] Sinusoidal
  - [ ] Logistic

### Probability
- [x] Permutation/combination
- [x] Randomization
  - random(lb, ub), random()
  - Shuffle list
  - Random element of list

### Vector/Matrix
- [x] Vector
  - [x] Compilation
  - [x] Dot product
  - [x] Cross Product
  - [x] Subscript access
  - [x] Addition/subtraction
  - [x] Angle between

- [x] Matrix
  - [x] Conversion to/from list/matrix
  - [x] Determinant
  - [x] Identity
  - [x] Multiplication
  - [x] Addition/Subtraction
  - [x] Transposition

### List math/operations
- [x] Zip, map, and reduce w/ anonymous closure arguments.
- [x] Sort and filter
- [x] Append and remove
- [ ] Insert
- [x] Chained subscript access
  - Access by index
  - Access by range
- [x] Size

### Boolean logic
- [x] Basic boolean operators
  - *And, or, xor, and not.*
- [ ] Commutative simplification 
  - *Only handles and & or for now*

### Programs/functions
- [x] Definition & deletion of variables and functions
  - *Support function overloading*
  - *Automatic scope management*
- [x] Runtime compilation
- [x] Flow control
  - Execution
    - *Line break*
    - *Line feed*
  - Loops
    - *Copy*
    - *Repeat*
    - *for (a: list) {...}*
    - *while (a) {...}*
  - Conditional statements
    - *Ternary operator '?'*
    - *If (predicate) {...}*
    - [ ] Else
    - [ ] Else if
- [x] I/O
  - *Program execution*
  - *Print, println*
  - *Log*
  - *Recursion*
  - *Return*
  - [ ] *Throw*
- [x] Strings
  - *Concatenation*
  - *Subscript access*
- [x] Tuples
  - *Compilation*
  - *Subscript access*
- [x] Error handling with try
- [x] System
  - *Precise date & time (down to nano seconds)*
  - *Performance measurement*
- [x] Scope management
  - Lock/unlock variables
  - Save/restore
- [x] Multi-line function/list/vector compilation
- [x] Trailing closure syntax
