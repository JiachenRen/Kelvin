Kelvin CAS
=============
[![Build Status](https://travis-ci.com/JiachenRen/kelvin-cas.svg?branch=master)](https://travis-ci.com/JiachenRen/kelvin-cas)
![Swift 4.2](https://img.shields.io/badge/swift-4.2-orange.svg)
[![License: MIT](https://img.shields.io/apm/l/vim-mode.svg?colorB=blue&style=flat)](/LICENSE)
![Carthage - Compatible](https://img.shields.io/badge/carthage-✓-orange.svg?style=flat)

Kelvin is a powerful computer algebra system built with _Swift 4_. It is similar to its close relative, _Java Algebra System_, only a gazilion times faster & cleaner. Find [more](https://github.com/JiachenRen/java-algebra-system) about JAS here.

## MacOS User Interface

Finally, the UI is here! Well, it is rather simple, but isn't that a good thing? Using `Highlightr` (which uses [highlight.js](https://highlightjs.org "highlight.js homepage") at its core), the editor supports **185** languages and **89** themes. That's just something extra and useless imo but hey, it looks great!

### Integrated Development Environment
Well, it is primitive as of now... but it gets the job done! It sort of works like the old [Swift Playground](https://developer.apple.com/swift-playgrounds/ "Apple's Introduction on Swift Playgrounds") - that is, as you edit your code, the editor automatically compiles and runs it for you! Only this time, it is faster (imo of course...). The window on the lower left is the `console`, all program outputs go in there. The window on the lower right is the `debugger`, all execution logs including compilation time, run time, errors, and step by step execution result go in there. 

Below is the Kelvin IDE in default `github` theme, highlighted using `ruby`'s syntax (keep in mind that you can choose from a large poo of candidates).

![Screenshot of IDE with GitHub Theme](/Misc/Screenshots/ruby_github_theme.png "IDE with GitHub theme")

Another one of the **85** themes you can choose from that is my personal favorite, `dracula`
![Screenshot of IDE with Dracula Theme](/Misc/Screenshots/ruby_dracula_theme.png "IDE with Dracula theme")

Try it out, 'cause it's awesome ~~ why not??

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
# Note: enter the statements line by line in the terminal. ommit the ← and → symbols
# to reproduce the result
$ kelvin

# Define a function fib(x) that finds the nth element of the fibonacci series
# In kelvin, this can be abbreviated into a single line: 
# def fib(n, #((if(n <= 1, #(return n)); return fib(n - 1) + fib(n - 2))))
# You don't want to do that! (Nobody would understand...)
← def fib(n) {
    if (n <= 1) {
        return n
    }
    return fib(n-1) + fib(n-2)
  }
→ done

# Test to see what the 10th element of the series is
← println fib(10)
→ 55

# Define a function listFib(n) that generates a fibonacci series of up to n elements
# Again, look at this one liner that means the same thing (seriously though, don't do this)
# def listFib(n, #(return 0...n | #(fib($1 + 1))))
← def listFib(n) {
    return map(0...n) {fib($1+1)}
  }
→ done

# Print the first 10 elements of the series, and sum them up
← println listFib(10)
→ {1, 1, 2, 3, 5, 8, 13, 21, 34, 55}

← s := sum(listFib(10))
→ done

← println s
→ 143

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
Hello World

# Alternatively, you can run the program with verbose on
$ kelvin -f -v /tmp/prg

# Program output under verbose mode
→ trying relative URL to current working directory...
→ loading contents of prg
→ compiling...
→ compilation successful in 0.03710794448852539 seconds.
→ starting...
→ timestamp: 1549690611.090765
→ begin program execution log:

    # 1
    → println "Hello World"
    = "Hello World"

→ end program execution log.
→ program terminated in 0.0023789405822753906 seconds.
Hello World
```
## The Kelvin Language
The Kelvin programming language is developed by a high school senior. Yes, really. It is a combination of `Javascript`, `Swift`, `Python`, and `Bash`, with a bunch of wierd syntatic sugars that came from my pure imagination. It is a interpreted language (nowhere near as fast), but it is powerful in terms of what it can do when it comes to solving high school math problems.
> As a side note, _Kelvin_ even has trailing closure syntax and anonymous arguments, a feature loved by Swift users!

### Examples
- Binary search algorithm written in `Kelvin`:
```ruby
# The conventional binary search algorithm written in kelvin language
# - arr: a sorted array of values (kelvin only has value types, but the inout modifier '&' makes up for it.)
# - search: the value to look up in arr. (kelvin does not have type safety, like js.)
def bin_search(arr, search) {
    c := 0;
    first := 0;
    n := size(arr);
    last := n - 1;
    middle := int((first + last) / 2);

    while (first <= last) {

        if (arr[middle] < search) {
            first := middle + 1;
            b := true;
        } else {
            middle := int((first + last) / 2);
        }

        if (arr[middle] == search) {
            return middle;
        } 
    }

    return "not found";
}

# Define a list l1
def l1 = {1, 2, 3, 5, 7, 8, 9, 10}

# 
println bin_search(l1, 8.5)
assert bin_search(l1, 9) == 6
```
- For loops, if statements, and while loops, etc. written in `Kelvin`:
```ruby
# A function that demonstrates if statement, while loop, map, and
# flow control keywords like return, continue, and break in kelvin.
def whatTheHeckDoesThisDo(a, b) {
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

def result = whatTheHeckDoesThisDo(1, 3)
assert print(result) == {114, 67}
```

For more examples (algebraic operations, calulus, stats, loops, conditional statements, error handling, closures, list operations, etc.), please refer to [Examples](Examples).

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
    - Derivative/gradient at point/vector
    - Tangent line/plane/surface/hyperplane/etc for multivariate functions
  
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
- [ ] Contains
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
- [x] Variables & Functions
  - *Definition & deletion*
  - *Overloading of functions*
  - *Automatic scope management*
  - *Closures*
  - *Anonymous closure arguments (e.g. $0, $1, ...)*
- [x] Runtime compilation
- [x] Flow control
  - Execution
    - *Line break (;)*
    - *Pipeline (->)*
  - Loops
    - *Copy*
    - *Repeat*
    - *for (a: list) {...}*
    - *while (a) {...}*
  - Conditional statements
    - *Ternary operator '?'*
    - *If (predicate) {...}*
    - *Else {...}*
    - *Else if (predicate) {...}*
  - Transfer
    - *Return*
  - Control
    - *Break*
    - *Continue*
- [x] I/O
  - *Program execution*
  - *Print, println*
  - *Log*
  - *Recursion*
  - *Return*
  - *Throw*
- [x] Strings
  - *Concatenation*
  - *Subscript access*
- [x] Pairs
  - *Compilation*
  - *Subscript access*
- [x] Error handling
  - *Try*
  - *Assert*
  - *Throw*
- [x] System
  - *Precise date & time (down to nano seconds)*
  - *Performance measurement*
- [x] Scope management
  - Lock/unlock variables
  - Save/restore
- [x] Multi-line function/list/vector compilation
- [x] Trailing closure syntax
