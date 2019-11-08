Kelvin CAS
=============
[![Build Status](https://travis-ci.com/JiachenRen/kelvin-cas.svg?branch=master)](https://travis-ci.com/JiachenRen/kelvin-cas)
![Swift 5.1](https://img.shields.io/badge/swift-5.1-orange)
[![License: MIT](https://img.shields.io/apm/l/vim-mode.svg?colorB=blue&style=flat)](/LICENSE)
![Carthage - Compatible](https://img.shields.io/badge/carthage-✓-orange.svg?style=flat)

Kelvin is a powerful language for symbolic computation built with _Swift 5_. Aside from APIs for advanced **statistic**, **algebra**, **linear algebra**, **probability**, **list** and **calculus** operations, it incorporates many popular syntactic constructs and features from many different languages. For a full list of what it can do, please refer to [Capabilities](#Capabilities). For documentation and examples, please refer to [Examples](/Examples)

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

## Kelvin CLI
If you prefer, you can use `kelvin` as a command line tool.
### Setup
1. Before proceeding, you must have the latest `git`, `carthage`, and `xcodebuild` installed.
2. Run the following command in terminal.

```bash
$ cd /tmp && curl https://raw.githubusercontent.com/JiachenRen/kelvin-cas/master/install.sh > install.sh && bash install.sh
```

3. You are done! Now try `kelvin`.


### Usage

```bash
Usage: kelvin (enter interactive mode)
  or  kelvin -e <expr> (evaluate the expression that follows)
  or  kelvin -f [options] <filepath> (execute file at path)

where options include:

   -v verbose
   -d debug
```

### Hello World in Kelvin

```bash

# Make a new file named "prg" containing a single line 'print "Hello World"' in /tmp directory
$ cd /tmp && echo "print \"Hello World\"" > prg

# Compile and run the program with verbose on
$ kelvin -f -v prg

# Program output under verbose mode
→ loading file at prg...
→ compiling...
→ compilation successful in 5 milliseconds.
→ start time: Sep 13, 2019 at 10:26:51 AM
→ begin execution log:
  # 1
  → print "Hello World"
  = Hello World

→ end execution log.
→ program terminated in 3 milliseconds.
Hello World
```

### Beautiful ANSI syntax highlighting in terminal

Kelvin command line interface comes with beautiful syntax highlighting. 

#### Dark UI
![Dark Mode](/Misc/Screenshots/kelvin_terminal_dark.gif)

#### Light UI
![Dark Mode](/Misc/Screenshots/kelvin_terminal_light.gif)

## MacOS User Interface

Finally, the UI is here! Using `Highlightr` (which uses [highlight.js](https://highlightjs.org "highlight.js homepage") at its core), the editor supports **186** languages and **89** themes. (That's just something extra and useless imo but hey, it looks great!) The `highlight.js` core is modified to support syntax highlighting for kelvin language, which is used by default.

### Integrated Development Environment
The IDE works like the old [Swift Playground](https://developer.apple.com/swift-playgrounds/ "Apple's Introduction on Swift Playgrounds") - that is, as you edit your code, the editor automatically compiles and runs it for you! Only this time, it is faster. The window on the lower left is the `console`, which serves as the program's `IO` interface. The window on the lower right is the `debugger`, all execution logs including compilation time, run time, errors & stack trace, and step by step execution result go in there. 

Below is a screenshot of Kelvin IDE in the default theme (keep in mind that you can choose from a large pool of candidates), highlighted using `kelvin`'s syntax . The screenshot demonstrates how to find the **tangent line/plane** of multivariate functions. (Notice how the whole script is compiled and evaluated in under **0.1 seconds**!) Even if the execution time lasts longer, there won't be any lagging since the scripts run on a separate thread and are cancelled/started automatically. 

![Finding Tangent with IDE and Kelvin](/Misc/Screenshots/kelvin_dark_theme.png)

## Use Kelvin in VSCode
You can now use Kelvin in **VSCode** by installing a plug-in! Just search for `Kelvin Lang` under `Install Extensions`, install it, and you are all set to go! The syntax highlighting rules for Kelvin are written using `TextMate`. 

![VSCode Screenshot 1](/Misc/Screenshots/kelvin_vscode_1.png)

You can run & debug kelvin script using VSCode's terminal (with proper syntax highlight even in debug messages)!

![VSCode Screenshot 2](/Misc/Screenshots/kelvin_vscode_2.png)

## The Kelvin Language
Kelvin was originally designed to be a CAS. Nevertheless, over the course of its development it gradually evolved into its own functional programming language, with all the nuances of a modern programming language such as **recursion**, **loops**, **if statements**, **higher order functions**, **anonymous closure arguments** , and so much more. Read the subsections below to get a taste of Kelvin.

### Performance
Kelvin is a interpreted language (nowhere near as fast), but it is powerful when it comes to solving math problems. For instance, one of the things that makes Kelvin unique is its **optimization engine**. For instance, suppose you have a function defined as
```ruby
def f(x, y) = x ^ 2 / x + y - x + y
```
For most languages, for instance `Python`, `Swift`, `C`, `Java`, etc., when the function `f` is fed with arguments `x` and `y`, the actual expression `x ^ 2 / x + y - x + y` is evaluated. Kelvin, however, handles things much more efficiently. First, the function definition is algebraically simplified to be `2y`. When you call function with undefined variables `a, b`, `a` is actually dropped for it no longer exists in the function definition. The function then apply its simplified definition `f(y) = 2y` on `a`, which results in `2a`.

### Syntax
The syntax of Kelvin is inspired by a variety of languages including `Javascript`, `Swift`, `Python`, and `Bash`. 
Just to whet your appetite, the documentation for defining functions and variables are included here.

#### Function Definition
```ruby
# Inline function definition:
def f(x) = 3x ^ 2 * log(g(x)) + a

# Which is equivalent to.
f(x) := 3x ^ 2 * log(g(x)) + a

# For more complicated functions, use multiline definition.
def f(a, b, c) {
    str := "";
    for (i: map(0...a) {$1}) {
        if (i % 2 == 0 nor (true xor c)) {
            str &= i
        } else if (c) {
            break
        } else {
            continue
        }
    };
    return str
}

# Higher order functions.
def f(g, a, b) {
    return g <<< {a, b}
}

def g(x, y) = x + y

# 'f' is a higher order function that can take in 'g' as argument.
# Call to f(g, 3, 4) returns 7.
f(g, 3, 4)

def f1(x) {x(3, 4)}
# Pass in x as a function reference
f1(*g) # returns 7
```

#### Variable Definition
```ruby
# Define a = 3
a := 3

# Equivalent to a := 3
def a = 3

# Equivalent to a := 3
define(a, 3)

# Define a as b, b as c, c as a, which will cause circular definition
a := b; b := c; c := d;
```

#### Custom Syntax
```ruby
# Define an infix function
infix a(x, y) { x && y xor false }

# Define a prefix function
prefix give(x) { x a (!x) nand true }

# Define a postfix function
postfix five(x) { x nor x }

me := true
scott := true
marcus := false

# Now try this!
give me and scott or marcus a high five

# If you are smart enough, the whole expression simplifies to
give me and scott or marcus a high five === !high

# Therefore, we also have
high := true
give me and scott or marcus a high five === false
high := false
give me and scott or marcus a high five === true

# What's more, you can have the interpreter automatically resolve associativity!
auto smarterThan(a, b) { lowercased(a) == "jiachen" }
assert "Jiachen" smarterThan "Anyone... you name it."
```

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
- Greatest common divisor & least common multiple
- Prime factors
- Big (I mean BIG) integers
- Prime number generation
- Factorize
- Factorial
    - Try `1000!`
- Round to decimal places
- Fraction
  - Enter fraction mode with `setMode("rounding", "exact")`
- Irrational number simplification
- Rounding mode
  - Exact vs approximate vs automatic

### Algebra
- Commutative simplification
- Preliminary factorization
- Expand
- Extract coefficients of polynomial
- Polynomial rational root finder
- Multinomial expansion
  - e.g. `rRoots(-4 * x ^ 2 + -43 * x + 3 * x ^ 3 + 84) === {3, -4, 7/3, -4}`
- [ ] Long division
- [ ] Complete the square
- [ ] Exponential simplification
- [ ] Solve
  - [ ] Numerical solve
  - [ ] Zeros
  - [ ] Algebraic solve

### Calculus
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
  - [ ] Limit
  
- [x] Integration
    - [x] Numerical integration (QAGS - accelerated by Peter Wynn’s epsilon algorithm)
    - [ ] Algebraic integration
    - [ ] Riemann sum

### Statistics
- One variable statistics
  - Summation
  - Average
  - Sum of difference squared
  - Variance
  - Std. deviation
  - Five-number summary, IQR
  - Outliers
- Two variable statistics
  - Sample/population covariance
  - Correlation
  - Coefficient of determination
  - ∑xy
  - OneVar X/Y
- Distributions
  - Normal Cdf (-∞ to x, from lb to ub, from lb to ub with μ and σ)
  - Random normal distribution (randNorm)
  - Normal Pdf
  - Inverse Normal
  - Inverse t
  - tPdf/tCdf
  - Binomial Cdf/Pdf
  - Geometric Cdf/Pdf
- Confidence intervals
    - z interval
    - t interval
    - 2 sample z interval
    - 2 sample t interval
    - 1 prop z interval
    - [ ] 2 prop z interval
- Regression
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
- Permutation/combination
  - ncr, npr for lists
- Randomization
  - `random(lb, ub)`, `random()`, `randomInt(lb, ub)`, `randomMat`, `randomBool`
  - Shuffle list
  - Random element from list

### Linear Algebra
- Vector
  - Dot product
  - Cross Product
  - Subscript access
  - Addition/subtraction
  - Angle between
  - Orthogonal projection
  - Orthogonal basis using Gram-Schmidt

- Matrix
  - Conversion to/from list/matrix
  - Determinant O(n^3)
  - Gaussian elimination
    - Row reduced echelon form (RREF)
    - Reduced echelon form (REF)
  - Identity
  - Cofactor
  - Transformation
  - Multiplication
  - Addition/Subtraction
  - Power
  - Transpose
  - Inverse
  - Adjoint
  - Characteristic polynomial
  - QR factorization
  - Distinct rational eigen values
  - Least squares solution
  - Augmentation
  - [ ] LU decomposition
  - [ ] Eigen values/vectors

### List math/operations
- Zip, map, and reduce w/ anonymous closure arguments.
- Sort and filter
- Append and remove
- Set at index
    - `set <index> of <list> to <element>`
- Insert
- Swap indices `i`, `j`
    - `swap {i, j} of <list>`
- Reverse
- Contains
- Chained subscript access
  - Access by index
  - Access by range
  - Access by `Key : Value`
    - Works exactly like a `JSON` object, but a lot more flexible!
- Count

### Boolean logic
- Basic/advanced boolean operators
  - And, or, not, xor, nand, and nor
- Complex boolean logic simplification
  - Decarte's Law and distributive properties of `and` and `or`
  - e.g. `!(!(!x && !(!y || x)) || !y)` simplifies to  `(!x && y)`

### Programs/functions
- Variables & Functions
  - **Higher order function** (function as parameter)
    - `invoke(<name of function>, <list of parameters>)`, operator `<<<`
    - function reference prefix operator `*`
  - Definition & deletion
  - Overloading of functions
  - Automatic scope management
  - **Closures**
  - Anonymous closure arguments {`$0`, ... , `$1`}
  - **Inout variables** (behaves like the reference operator `&`, but not quite)
  - List/clear all vars/funcs
- Runtime environment 
  - `run <file at path>`
  - `import <file at path>`
  - `compile <kelvin script>`
  - `eval <kelvin script>`
- Flow control
  - Line break `;`
    - Pipeline `->`
  - Loops
    - `copy`
    - `repeat`
    - `for (a: <list>) {...}`
    - `while (a) {...}`
  - Conditional statements
    - Ternary operator `?`
    - `if (<bool>) {...}`
    - `else {...}`
    - `else if (<bool>) {...}`
  - Breaking out of function or loop
    - `return`
    - `break`
    - `continue`
- I/O & File System
  - Read file
  - Write/append to file
  - Automatic rel/abs path mapping
  - List paths
  - Remove/create file/folder
  - Print, println
  - Log
  - Get/set working directory
  - Read line from UI
- Strings
  - Concatenation
  - Subscript access
  - Cast to list of `@char`
  - Replace
  - Contains
  - **Support for regex**
    - Matches & replace
- Pairs
  - Prepositions for readability
    - `to`, `from`, `of`, `at`, etc.
  - Subscript access
- Error handling
  - `try` blocks, ternary `try` statement
  - `assert <bool>`
  - `throw <any>`
- Stack Trace
    - Record full call stack history
    - Print stack trace
    - Enable/disable stack trace
    - Untrack specific functions, both native & user defined
- System
  - Date & time (down to nano seconds)
  - Performance measurement
    - `measure {<block>}`
  - Full interoperability with `shell`
- Scope management
  - Lock/unlock variables
  - Save/restore
- Multi-line function/list/vector compilation
- Trailing closure syntax
