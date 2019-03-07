Kelvin CAS
=============
[![Build Status](https://travis-ci.com/JiachenRen/kelvin-cas.svg?branch=master)](https://travis-ci.com/JiachenRen/kelvin-cas)
![Swift 4.2](https://img.shields.io/badge/swift-4.2-orange.svg)
[![License: MIT](https://img.shields.io/apm/l/vim-mode.svg?colorB=blue&style=flat)](/LICENSE)
![Carthage - Compatible](https://img.shields.io/badge/carthage-✓-orange.svg?style=flat)

Kelvin is a powerful language for symbolic computation built with _Swift 4_. Aside from APIs for advanced **statistic**, **algebra**, **linear algebra**, **probability**, **list** and **calculus** operations, it incorporates many popular syntactic constructs from different languages (lua, python, swift, java, javascript, bash). For a full list of what it can do, please refer to [Capabilities](#Capabilities).

## Using Kelvin as a Framework

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Highlightr into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "JiachenRen/kelvin-cas"
```

Run `carthage update` to build the framework and drag the built `Kelvin.framework` into your Xcode project.


> **Note** - If `carthage update` fails with the `Kelvin-iOS` framework, you can still build it manually from Xcode. 
Otherwise if you are only using the macOS Framework, do ```carthage update --platform macOS``` instead.

## Command Line
If you prefer, you can use `kelvin` as a command line tool.
### Setup
1. Before proceeding, you must have the latest `git` and `xcodebuild` installed.
2. Run the following command in terminal.

```bash
$ cd /tmp; curl https://raw.githubusercontent.com/JiachenRen/kelvin-cas/master/install.sh > install.sh; bash install.sh
```

3. You are done! Now try `kelvin -c`.


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
# def fib(n, $((if(n <= 1, $(return n)); return fib(n - 1) + fib(n - 2))))
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
# def listFib(n, $(return 0...n | $(fib($1 + 1))))
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

# Make a new file named "prg" containing a single line 'print "Hello World"' in /tmp directory
$ cd /tmp; echo "print \"Hello World\"" > prg

# Compile and run the program with verbose on, highlighted with ANSI
$ kelvin -f -vc prg

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

## MacOS User Interface

Finally, the UI is here! Using `Highlightr` (which uses [highlight.js](https://highlightjs.org "highlight.js homepage") at its core), the editor supports **186** languages and **89** themes. (That's just something extra and useless imo but hey, it looks great!) The `highlight.js` core is modified to support syntax highlighting for kelvin language, which is used by default.

### Integrated Development Environment
The IDE works like the old [Swift Playground](https://developer.apple.com/swift-playgrounds/ "Apple's Introduction on Swift Playgrounds") - that is, as you edit your code, the editor automatically compiles and runs it for you! Only this time, it is faster. The window on the lower left is the `console`, which serves as the program's `IO` interface. The window on the lower right is the `debugger`, all execution logs including compilation time, run time, errors & stack trace, and step by step execution result go in there. 

Below is a screenshot of Kelvin IDE in the default theme (keep in mind that you can choose from a large poo of candidates), highlighted using `kelvin`'s syntax . The screenshot demonstrates how to find the **tangent line/plane** of multivariate functions. (Notice how the whole script is compiled and evaluated in under **0.1 seconds**!) Even if the execution time lasts longer, there won't be any lagging since the scripts run on a separate thread and are cancelled/started automatically. 

![Finding Tangent with IDE and Kelvin](/Misc/Screenshots/finding_tangent.png)

Another one of the **85** themes you can choose from that is my personal favorite, `tomorrow-night-blue`
![Screenshot of IDE with Dark Theme](/Misc/Screenshots/kelvin_tomorrow_night_blue_theme.png)

Try it out, 'cause it's awesome ~~ why not??

### Support for Dark Mode on Sierra
The IDE now automatically chooses/changes its theme according to the system's theme! (You can still customize if wanted)

## The Kelvin Language
The Kelvin programming language is developed by a high school senior. Yes, really. It is a combination of `Javascript`, `Swift`, `Python`, and `Bash`, with a bunch of wierd syntatic sugars that came from my pure imagination. It is a interpreted language (nowhere near as fast), but it is powerful in terms of what it can do when it comes to solving high school math problems.
> As a side note, _Kelvin_ even has trailing closure syntax and anonymous arguments, a feature loved by Swift users!

### Examples
Please refer to [Examples](Examples) for detailed documentation/examples over algebraic operations, calulus, stats, loops, conditional statements, error handling, closures, list operations, etc.

## Capabilities

### Arithmetic
- [x] Standard binary operations
  - Addition
  - Subtraction
  - Multiplication
  - Division
  - Exponentiation
- [x] Unary operations (many, see below)

### Number
- [x] Greatest common divisor & least common multiple
- [x] Prime factors
- [x] Round to decimal places
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
- [ ] Limit
- [x] Differentiation
  - Logarithmic differentiation
  - nth derivative
  - Multivariate (Calculus III)
    - Partial derivatives
    - Implicit differentiation
    - Directional differentiation
    - Gradient
    - Derivative/gradient at point/vector
    - Tangent line/plane/surface/hyperplane/etc for multivariate functions
  
- [x] Integration
    - [x] Numerical integration (QAGS - accelerated by Peter Wynn’s epsilon algorithm)
    - [ ] Algebraic integration
    - [ ] Riemann sum

### Statistics
- [x] One variable statistics
  - Summation
  - Average
  - Sum of difference squared
  - Variance
  - Std. deviation
  - Five-number summary, IQR
  - Outliers
- [x] Two variable statistics
  - Sample/population covariance
  - Correlation
  - Coefficient of determination
  - ∑xy
  - OneVar X/Y
- [x] Distributions
  - Normal Cdf (-∞ to x, from lb to ub, from lb to ub with μ and σ)
  - Random normal distribution (randNorm)
  - Normal Pdf
  - Inverse Normal
  - Inverse t
  - tPdf/tCdf
  - Binomial Cdf/Pdf
  - Geometric Cdf/Pdf
- [x] Confidence intervals
    - [x] z interval
    - [x] t interval
    - [x] 2 sample z interval
    - [x] 2 sample t interval
    - [x] 1 prop z interval
    - [ ] 2 prop z interval
- [x] Regression
  - [x] Linear (least squares regression)
    - Residuals
  - [ ] Multiple linear regression
  - [x] Polynomial
    - [ ] Quadratic, cubic, quartic
  - [ ] Power
  - [ ] Exponential/logarithmic
  - [ ] Sinusoidal
  - [ ] Logistic
- [ ] Stat Tests
  - [ ] One/two sample/prop t test
  - [ ] One/two sample/prop z test

### Probability
- [x] Permutation/combination
- [x] Randomization
  - random(lb, ub), random()
  - Shuffle list
  - Random element of list

### Linear Algebra
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
  - [x] Cofactor
  - [x] Transformation
  - [x] Multiplication
  - [x] Addition/Subtraction
  - [x] Transposition
  - [ ] LU decomposition
  - [ ] Inverse
  - [x] Gaussian elimination

### List math/operations
- [x] Zip, map, and reduce w/ anonymous closure arguments.
- [x] Sort and filter
- [x] Append and remove
- [ ] Insert
- [x] Reverse
- [x] Contains
- [x] Chained subscript access
  - Access by index
  - Access by range
  - Access by `Key : Value`
    - Works exactly like a `JSON` object, but a lot more flexible!
- [x] Size

### Boolean logic
- [x] Basic boolean operators
  - And, or, xor, and not.
- [ ] Commutative simplification 
  - Only handles and & or for now

### Programs/functions
- [x] Variables & Functions
  - Definition & deletion
  - Overloading of functions
  - Automatic scope management
  - Closures
  - Anonymous closure arguments (e.g. $0, $1, ...)
  - Inout variables (behaves like the reference operator "&", but not quite)
- [x] Runtime compilation
- [x] Flow control
  - Execution
    - Line break (;)
    - Pipeline (->)
  - Loops
    - Copy
    - Repeat
    - for (a: list) {...}
    - while (a) {...}
  - Conditional statements
    - Ternary operator '?'
    - If (predicate) {...}
    - Else {...}
    - Else if (predicate) {...}
  - Transfer
    - Return
  - Control
    - Break
    - Continue
- [x] I/O
  - Program execution
  - Print, println
  - Log
  - Recursion
  - Return
  - Throw
  - Get current directory path
  - Read line
  - [ ] Read file
- [x] Strings
  - Concatenation
  - Subscript access
- [x] Pairs
  - Compilation
  - Subscript access
- [x] Error handling
  - Try
  - Assert
  - Throw
- [x] System
  - Precise date & time (down to nano seconds)
  - Performance measurement
- [x] Scope management
  - Lock/unlock variables
  - Save/restore
- [x] Multi-line function/list/vector compilation
- [x] Trailing closure syntax
