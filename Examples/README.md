#  Examples
This directory contains various examples that demonstrate how to the Kelvin language, from **basic programming capabilities** including _variable/function definition_, _loops_, _if statements_, _error handling_, etc. to powerful **built-in APIs** that carry advanced algebraic operations like _factorization_, _stat calculations_ (normCdf, regression, etc.), _differentiation_, etc. 

## Table of Contents
- Algebra
    - [Trigonometry](/Examples/Algebra/Trigonometry.kel)
    - [Factorize](/Examples/Algebra/Factor.kel)
    - [Expand](/Examples/Algebra/Expand.kel)
    - [Boolean logic simplification](/Examples/Algebra/BooleanLogic.kel)
- Algorithms
    - [Binary search](/Examples/Algorithms/BinarySearch.kel)
    - [Deconstruct](/Examples/Algorithms/Deconstruct.kel)
    - [Recursion](/Examples/Algorithms/Recursion.kel)
    - [Contains](/Examples/Algorithms/Contains.kel)
- Linear Algebra
    - [Matrix](/Examples/LinearAlgebra/Matrix.kel)
    - [Vector](/Examples/LinearAlgebra/Vector.kel)
- Statistics
    - [One variable statistics](/Examples/Statistics/OneVar.kel)
    - [Distribution](/Examples/Statistics/Distribution.kel)
    - [Regression](/Examples/Statistics/Regression.kel)
    - [Confidence intervals](/Examples/Statistics/ConfidenceInterval.kel)
- Calculus
    - [Differentiation](/Examples/Calculus/Differentiation.kel)
    - [Integration](/Examples/Calculus/Integration.kel)
- Core
    - [Benchmarking](/Examples/Core/Benchmarking.kel)
    - [Debugging](/Examples/Core/Debugging/StackTrace.kel)
    - [Dictionary](/Examples/Core/Dictionary.kel)
    - [Error handling](/Examples/Core/ErrorHandling.kel)
    - Flow Control
        - [Conditional statements](/Examples/Core/FlowControl/Conditionals.kel)
        - [For loop](/Examples/Core/FlowControl/Loops/ForLoop.kel)
        - [While loop](/Examples/Core/FlowControl/Loops/WhileLoop.kel)
    - [Function](/Examples/Core/Function.kel)
    - [Higher order function](/Examples/Core/HigherOrderFunction.kel)
    - [IO](/Examples/Core/IO/IO.kel)
    - [List](/Examples/Core/List.kel)
    - [Subscript access](/Examples/Core/Subscript.kel)
    - [Trailing closure syntax](/Examples/Core/TrailingClosure.kel)
    - [Variable](/Examples/Core/Variable.kel)
    - [Working with string](/Examples/Core/String.kel)
    - [Run shell script](/Examples/Core/RunShell.kel)
    
### Just to whet your appetite...

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
        };

        if (arr[middle] == search) {
            return middle;
        } 
    };

    return "not found";
}

# Define a list l1
def l1 = {1, 2, 3, 5, 7, 8, 9, 10}

# 
println bin_search(l1, 8.5)
assert bin_search(l1, 9) == 6
```

## Using Kelvin with macOS built-in Grapher

You can copy and paste the output from kelvin directly into the built-in `Grapher` to graph it. The following screenshots demonstrate using kelvin to compute a tangent plane in terminal. You can then use `Grapher` to graph it.
    
![Kelvin](/Misc/Screenshots/tangent_plane_kelvin.png)

## Show me the code!
This is a comprehensive demonstration of how you can use Kelvin to suit your mathematical needs!

<!-- AUTOMATIC DOC -->
### [Algebra/BooleanLogic](/Examples/Algebra/BooleanLogic.kel)
```ruby
# Test boolean logic simplification

# Test for base cases
# a and a is a
assert (a && a) == a
assert (a && b && a) == (a && b)
# a or a is a
assert (a || a) == a
assert (a || b || a) == (a || b)
# not not a is a
assert !(!a) == a
assert (a && !(!a)) == a
# a or false is a
assert (a || false || b) == (a || b)
assert (a || b || false) == (false || b || a)
assert (a || b || false) == (a || b)
# a or true is true
assert (a || true) == true
# a and ... and false is false
assert (a && b && false) == false
assert (false && a && b) == false
assert (b && false && a) == false
# a and true is a
assert (a && b && true) == (a && b)
# a and not a is false
assert (a && b && !(!(!a))) == false
# a or not a is true
assert (a || b || !a) == true
# a and (b or a) is a
assert (a && (b || a)) == a
assert ((a || b) && b) == b
assert (a && (b || (b && a))) != a
# a or (a and b) is a
assert (f() && g() || f()) == f()

# Test for complex cases (where expanding & factoring are needed)
assert ((!a || b) && (a || b)) == b
assert (!a && (a || b)) == (!a && b)
assert ((a && b) || (a && c)) == (a && (b || c))
assert ((a || b) && (a || c || d)) == (a || b && (c || d))

def f1(a, b, c, d) {
    return ((a || b) && (a || c || d))
}

def f2(a, b, c, d) {
    return a || b && (c || d)
}

def randBool() {
    return int(random() * 2) == 0
}

def randBool(i) {
    return randBool()...i
}

def test(f, g, i) {
    tmp := randBool(4);
    return ((f <<< tmp) == (g <<< tmp))...i
}

assert test(f1, f2, 10) == (true...10)
assert (a or (b and (c or a))) == (a || b && c)
assert (a or (b and (c or !a))) == (a || b)

# The ultimate test, from CS 2051 HW
assert !(!(!x && !(!y || x)) || !y) == (!x && y)
assert (not (not (not x and not (not y or x)) or not y)) == (not x and y)
```
### [Algebra/Expand](/Examples/Algebra/Expand.kel)
```ruby
assert expand((a + b)(a - b)) == a ^ 2 - b ^ 2
assert expand((a - b) ^ 3) == a ^ 3 + 3 * a * b ^ 2 - 3 * a ^ 2 * b - b ^ 3
# assert expand(3 ^ (b - 3)) == 3 ^ -3 * 3 ^ b
assert expand((a + b) ^ (4 - a * 5))
assert expand((a + b) ^ (4 + a)) == (a + b) ^ a * 4 * a * b ^ 3 + (a + b) ^ a * 4 * a ^ 3 * b + (a + b) ^ a * 6 * a ^ 2 * b ^ 2 + (a + b) ^ a * a ^ 4 + (a + b) ^ a * b ^ 4
assert expand((a + b) ^ (-5 * a + 4)) =i= (a + b) ^ (-5 * a) * 4 * a * b ^ 3 + (a + b) ^ (-5 * a) * 4 * a ^ 3 * b + (a + b) ^ (-5 * a) * 6 * a ^ 2 * b ^ 2 + (a + b) ^ (-5 * a) * a ^ 4 + (a + b) ^ (-5 * a) * b ^ 4
```
### [Algebra/Factor](/Examples/Algebra/Factor.kel)
```ruby
# Behold, factorization!

factor(x * a + x + a + 1)
factor(x * c + x * b + c * a + b * a)
factor(x * a + x * 2 + a + 2)
factor(z * b + z * a + y * b + y * a + x * b + x * a)
factor(z * d * a + z * b + y * d * a + y * b + x * d * a + x * b)
factor(z * d * a + z * b * 2 + y * d * a + y * b * 2 + x * d * a + x * b * 2)
factor(r * b * a + d * b * a - d * c * a * 2 - r * c * a * 2)
factor(x * f * c + x * f * b + x * d * c + x * d * b + f * c * a + f * b * a + d * c * a + d * b * a)
```
### [Algebra/Trigonometry](/Examples/Algebra/Trigonometry.kel)
```ruby
# Prints 1!!!!
println tan(x) * sec(x) * csc(x) * cos(x) ^ 2
```
### [Algorithms/BinarySearch](/Examples/Algorithms/BinarySearch.kel)
```ruby
# Conventional binary search algorithm implemented in kelvin!
def bin_search(arr, search) {
    c := 0;
    first := 0;
    n := size(arr);
    last := n - 1;
    middle := int((first + last) / 2);

    # This is a while loop
    while (first <= last) {
        b := false;

        if (arr[middle] < search) {
            first := middle + 1;
            b := true;
        };

        if (arr[middle] == search) {
            return middle;
        };

        if (!b) {
            last := middle - 1;
        };

        middle := int((first + last) / 2);
    };

    return "not found";
}

def l1 = {1, 2, 3, 5, 7, 8, 9, 10}
assert println(bin_search(l1, 8.5)) == "not found"
assert bin_search(l1, 9) == 6
```
### [Algorithms/Contains](/Examples/Algorithms/Contains.kel)
```ruby
# A function that checks if list contains a
def contains(list, a) {
    for (e: list) {
        if (e == a) {
            return true
        }
    };
    return false
}

# Prints true
println contains({1, 2, 3}, 2)

# Prints false
println contains({1, 2, 3}, x)
```
### [Algorithms/Deconstruct](/Examples/Algorithms/Deconstruct.kel)
```ruby
def deconstruct(n) {
    if (n is @function) {
        return deconstruct(n as @list)
    };

    if (n is @list) {
        return map(n) {
            deconstruct($0)
        }
    };

    return n
}

println deconstruct(a*b+c^d*f)
```
### [Algorithms/FlatMap](/Examples/Algorithms/FlatMap.kel)
```ruby
def flatMap(l) {
    tmp := {};

    for (element: l) {
        if (element is @list) {
            tmp := tmp ++ flatMap(element);
            continue;
        };
        tmp := tmp ++ element;
    };

    return tmp
}

original := {1, {1, {1, 2, 3}, 2}, {3, 4}, 4, 5}
flat := flatMap(original)
println "original: " & original
println "flat mapped: " & flat
assert flat == {1, 1, 1, 2, 3, 2, 3, 4, 4, 5}
```
### [Algorithms/Recursion](/Examples/Algorithms/Recursion.kel)
```ruby
def f(a) {
    if (a > 10) {
        println a;
        return f(a / 10)
    };
    return a
}

println f(1000005)
println f(15)
```
### [Calculus/Differentiation](/Examples/Calculus/Differentiation.kel)
```ruby
# Define f as a function of x, y, z
def f(x, y, z) = x(x, y, z) + y(x, y, z) + z(x, y, z)

# define x, y, z as functions of u, s, t
def x(u, s, t) = u^2 + s * cos(t)
def y(u, s, t) = t^s + ln(u) / atan(s)
def z(u, s, t) = u + s / t ^ abs(u)

# Partial differentiation
def df_du = derivative(f(u, s, t), u)
def df_ds = derivative(f(u, s, t), s)
def df_dt = derivative(f(u, s, t), t)

println "∂f/∂u = " & df_du
println "∂f/∂s = " & df_ds
println "∂f/∂t = " & df_dt

def g(x) = x^3 + ln(cos(x))*sin(x)

# Shorthand for first derivative
println g(x ^ 2)'x

println derivative(x ^ 2 + f(x) * x, x)

# Preliminary implicit differentiation
println "\nImplicit differentiation: "
println impDif(y ^ 2 + y * x ^ 2 = y ^ 3 + y * x * b + y * x * a, x, y)

# Gradient of a function
println "\nGradient: "
def f(x, y, z) = z + x ^ 2 + x * 3 + log(y) ^ 2 * 4
println grad(f(x, y, z), {x, y, z})

def f(x, y, z) = y * 2 + x ^ 2 - z * 4
println f(x, y, z) grad {x, y, z}

# Directional differentiation
println "\nDirectional differentiation:"
println dirDif(f(x, y, z), {x, y, z}, [a, b, c])

# Gradient at specific point
def f(x, y, z) = z ^ 2 + 2y * x + x ^ 3
def g = (f(x, y, z) grad {x, y, z} << x = 3 << y = 2 << z = 1)
assert g == [31, 6, 2]

# Another way to use point specific evaluation
def f(x,y) = x^2 + x*y^2
assert (f(x, y)'x << {x = 3, y = 4}) == 22
assert (f(x, y)'y << {x = 3, y = 4}) == 24
assert (f(y, x)'x << {x = 3, y = 4}) == 24
assert (f(x, y)'x << {x = 3, y = 4}) == 22


def f(x, y, z) = 2x * y + 3x + 2y + x^2 + z^3
def g1 = (f(x, y, z) grad {x, y, z} << {x = 2, y = 2, z = 6})
assert g1 = [13, 8, 108]

def g2 = (f(x, y, z) grad {x, y, z} << {x = a, y = b, z = c})
assert g2 == [2 * a + 2 * b + 3, 2 + 2 * a, 3 * c ^ 2]

# Finding the tangent line/plane/surface/hyper-blablabla in higher dimensions
def f(x,y,z) = x ^ 2 + 2 * x * y + z ^ 3
def p = [1, 2, 3]
def t = tangent(f(x, y, z), {x, y, z}, p)

print "Equation of tangent plane for function " & f(x, y, z)
print " at point " & p & " is "
println t & "\n"

def g(x, y) = x ^ 2 + y ^ 3
def points = {[1, 2], [2, 3], [4, 9], [a, b]}
for (point: points) {
    print "Tangenet line for " & g(x, y) & " at " & point & " is ";
    println tangent(g(x,y), {x,y}, point)
}
```
### [Calculus/Integration](/Examples/Calculus/Integration.kel)
```ruby
assert nIntegrate(1 / x ^ 2, x, 1, inf) == 1
```
### [Core/Benchmarking](/Examples/Core/Benchmarking.kel)
```ruby
# Calculate the time to compute 10000 random numbers
a := time();
random()...10000;
println("time = " & time() - a)

# Get the current date
println date()

# Alternatively, use a measure block
def expr = factor(x * f * c + x * f * b + x * d * c + x * d * b + f * c * a + f * b * a + d * c * a + d * b * a)

# Measure the time it takes to factor 'expr'
measure {factor(expr)}

# Measure the time average of factorizing 'expr' 10 times
measure(10) {factor(expr)}
```
### [Core/Debugging/StackTrace](/Examples/Core/Debugging/StackTrace.kel)
```ruby
# This file demonstrates how you can use stack trace for debugging purposes.

# First enable stack trace.
setStackTraceEnabled(true)

# Now, put the first block of code you want to capture here
def f(x) {
    return x == 0 ? x * f(x - 1)
}
f(10)
println("This is recorded")

# Now disable stack trace
setStackTraceEnabled(false)

# Beyond this point, you can write code whose stack calls won't be recorded
println("This is not recorded")

# You can enable stack trace again to capture a second block, third, and so on.
setStackTraceEnabled(true)

def g(a, b) {
    return f(a) - f(b) ^ 2
}
g(3, 7)

setStackTraceEnabled(false)

# Now, to see the stack trace, simply call
printStackTrace()

# Since stack trace is cummulative, we can clear it.
clearStackTrace()

# You can also untrack selected calls
# For the following section, all elementary arithmetic operations are untracked
setStackTraceEnabled(true)
setStackTraceUntracked({"+", "-", "*", "/", "^"})
factor(a*3+a*b)
setStackTraceEnabled(false)
printStackTrace()
clearStackTrace()

# You should only be able to see
# - PUSH(factor) factor(3 * a + a * b)
# - POP(factor) (3 + b) * a
```
### [Core/Dictionary](/Examples/Core/Dictionary.kel)
```ruby
def dict = {
    1,
    2,
    3,
    a,
    b,
    "what": ("is": {"this", shit^2}),
    d: e,
    d: q,
    c: {a, b},
    m: {m, o: {r, p, g}}
}

dict[d]
dict[c][0]
dict["what"][1]
√dict["what"][1][1]
dict[shit]

# Prints rpg
println dict[m][o] ~ $0 & $1

```
### [Core/ErrorHandling](/Examples/Core/ErrorHandling.kel)
```ruby
# Try statements
msg1 := (try ({1, 2, 3} zip {1, 2}) : "an error has occurred.")
msg2 := (try ({1, 2, 3} zip {1, 2}))

println msg1
println msg2

# To throw an error
def err() {
    throw "shit happened"
}
try err() : "shit happened"

# Assertions
assert true
try (assert false) : "assertion was false"
```
### [Core/FlowControl/Conditionals](/Examples/Core/FlowControl/Conditionals.kel)
```ruby
# A simple if statement (same syntax as in most languages)
# Important - semicolons are mandatary in closures
a := 1
if (a == 1) {
    # Prints 1 and increment a by 1
    println "a is 1";
    a++;
}

# Make sure that a is 2 at this point.
assert a == 2

# "a+=2" increments the value of a by 2, then returns the value of a.
if ((a+=2) == 2) {
    println "This should not happen!"
} else if (a == 3) {
    println "This shouldn't happen either!"
} else {
    println "a is actually " & a
}

# Ternary conditional statement
a := (a < 10 ? 0 : 10)
assert a == 0
```
### [Core/FlowControl/Loops/ForLoop](/Examples/Core/FlowControl/Loops/ForLoop.kel)
```ruby
# Declare a list, l1
def l1 = {1, 2, 3, x, a, f(x), x + a}

# A simple for loop that iterates through every element in the list
# Prints "1, 2, 3, x, a, f(x), a + x, " in console.
for (e: l1) {
    print e & ", "
}
println ""

# Let's make it a bit more interesting.
# using map(), we match every element in the list with its index, then print out each pair.
# There are a few things happening here - $0 refers to the element in the list,
# while $1 refers to the index of that element. The map function iterates through
# the list and turns each element into a Pair, a unique DT in Kelvin that is essentially
# an ordered list with only two elements.
# The following loop prints "(1 : 0), (2 : 1), (3 : 2), (x : 3), (a : 4), (f(x) : 5), (a + x : 6), " to io.
for (p: map(l1) {$0: $1}) {
    print p & ", "
}
println ""

# You can access list and elements with subscripts
# There are two ways to subscript - with :: accessor and [].
# The following code demonstrates the use of both
l2 := {}
for (p: map(l1) {$0: $1}) {
    def element = p[0] + l1::p[1];
    l2 := (l2 append element)
}

# Prints {2, 4, 6, 2 * x, 2 * a, 2 * f(x), 2 * a + 2 * x}
# See if you can figure out what's happening given that
# p[0] refers to the element, while p[1], the second element
# of the pair, refers to the index.
println l2
assert l2 == {2, 4, 6, 2 * x, 2 * a, 2 * f(x), 2 * a + 2 * x}

# Iterate through a string with for loop
def str = "hello world"
def chars = ""
for (c: str as @list) {
    chars &= c;
    print c
}
assert chars == str

# How to use stride(lowerBound, upperBound, step)
# Prints "0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "
for (i: stride(0, 10, 1)) {
    print i & ", "
}

# stride also works with decimals
# This time, only "0, 1, 2, 3, 4, 5, 6, 7, 8, 9, " is printed to output
for (i: stride(0, 9.9, 1)) {
    print i & ", "
}

# Prints 0, 0.1, 0.2, ..., 10
for (i: stride(0, 10, 0.1)) {
    print i & ", "
}
```
### [Core/FlowControl/Loops/WhileLoop](/Examples/Core/FlowControl/Loops/WhileLoop.kel)
```ruby
def a = 0;
while (a < 10) {
    a++;
}
assert a == 10
```
### [Core/Function](/Examples/Core/Function.kel)
```ruby
# Syntax for defining inline function
def f(x) = x^3 / a
assert f(a) == a^2

# Alternatively, use the assignment operator :=
f(a, b) := a^2 - b
def l1 = {1, 2, 3}
assert f(l1, 2) = {-1, 2, 7}
l := ("hello world" as @list).map {$0 & $1}

# Syntax for defining a multiline function
def foo(a, b) {
    while (a < 100 || b < 100) {
        println "a = " & a;
        a := a + 1;
        if (a > 50) {
            b++;
        };
        if (b % 3 == 0) {
            println b & " is a multiple of 3";
            for (i: map(0...10) {$1}) {
                print i
            };
            print "\n";
            continue;
        };
        println "b = " & b;
        if (b > 66) {
            break;
        }
    };

    return {a, b}
}

def result = foo(1, 3)
assert print(result) == {114, 67}

# List all user defined functions
listFuncs()

# Clear all user defined functions
clearFuncs()
```
### [Core/HigherOrderFunction](/Examples/Core/HigherOrderFunction.kel)
```ruby
# invoke is represented by <<<, where lhs is the name of the function to invoke and rhs is list of arguments
def f(x, y, a, b) {
    # This is equivalent to 'invoke(x, {invoke(y, {a, b + a}), b^2, c})'
    return x <<< (y <<< (a, b + a), b^2, c)
}

def f(a, b, c) {
    return a - b * c
}

def g(a, b) {
    return a ^ b
}

# Prints -16 * c + 2187
println(f(f, g, 3, 4))

# There is another way to pass in functions as parameters.
# Define f, that takes in g as parameter
def f(g, x) {
    return g(x)
}

# Define a, a primitive function
def a(x) {
    return x^2
}

# Define b, a primitive function
def b(x) {
    return x^3
}

# Define c, a function that looks up and invokes the arbitrary definitions a, b
def c(x) {
    return {a,b}[0] <<< {b <<< {x}}
}

# Invoke c
assert c(3) == 729

assert f(*{a,b}[0],x) == x ^ 2
def test() {
    map({a, b, c}) {
        try f(*$0, x) : undef
    }
}
result := test()

assert (result contains undef) == false
assert result == {x^2, x^3, x^6}
```
### [Core/IO/IO](/Examples/Core/IO/IO.kel)
```ruby
# To read from input
# name := readLine()

# To print to output
println("Hello, " & name)

# To get current working directory
println getWorkingDir()

# Set current working directory
setWorkingDir("/tmp")

# Read file at path (if no '/' at the beginning, relative path to working dir. is used)
# readFile("/Users/jiachenren/iCloudDrive (Archive)/Documents/Developer/Kelvin/Examples/Developer/Benchmarking")

# Creating a directory named "folder" relative to "/tmp"
# If a file/folder named folder already exists, an error is thrown.
createDir("folder")

# Change to the dir just created
setWorkingDir("folder")

# Create a new file named "file.txt"
# Overwrites previous content
createFile("file.txt")

# Write to the file
writeToFile("file.txt", "println \"Hello World!\"\n")

# Append to existing file (an error is thrown if file does not exist.)
# Use either relative(relative to working dir) or absolute path.
appendToFile("file.txt", "println (a + b - a)")

# Checks if the path given is a directory
assert isDir("file.txt") == false

# List paths under "/tmp/folder"
assert listPaths() == {"file.txt"}

# Let's run the file we just created!
run "file.txt"

# Delete everything! Be careful!
assert getWorkingDir() == "/tmp/folder"
removePath("/tmp/folder")


```
### [Core/List](/Examples/Core/List.kel)
```ruby
def l1 = {1, 2, 3, 4, 5}

# Append
def l2 = (l1 ++ {6, 7, 8, 9, 10})
assert l2 == map(1...10) {$1 + 1}

# Map
def l3 = (l2 | $0 + $1)
assert l3 == map(l2) {$0 + $1}

# Filter
def l4 = (l1 |? $0 % 2 == 0)

# Sort
def l5 = (l1 >? $0 > $1)

# Reduce
n := (l2 ~ $0 + $1 ^ 2)

# Remove
l1 := (l1 rm 3)

# Subscript by range
l6 := l1[1,3]
assert l6 == {2, 3}

# Reverse
print(l1)
assert reverse(l1) == {5, 3, 2, 1}

# Produces "gip a ma I"
reverse("I am a pig" as @list) ~ $0 & $1

# Mutating a list at index
my_list := {2, 3, 7, 9}
set(my_list, 3, "pig")
assert my_list == {2, 3, 7, "pig"}
```
### [Core/Multiline](/Examples/Core/Multiline.kel)
```ruby
def f(a,b,c) = (
    a := 3;
    b := 4;
    c := a / b;
    c + a + b
)

def g(x) = (
    (x == 0) ? 1 : (
        x * g(x - 1)
    )
)

g(10)

println g(10)

def l1 = {
    "Hello",
    "World"
}

println l1

def fibonacci(x) = (
    (x == 0 || x == 1 || x == 2) ? (1...x) : (
        q := {1, 1};
        repeat(
            q := (q ++ q[size q - 2] + q[size q - 1]),
            x - 2
        )
    );
    q
)

println fibonacci(11)
```
### [Core/RunShell](/Examples/Core/RunShell.kel)
```ruby
def shellAdd(a, b, $(script := a & "+" & b; return replace(shell "echo '" & script & "' | bc", "\n", "") !! @number))

# Using shell to add 2 numbers!!!
println shellAdd(10000, 23423.25)
assert shellAdd(10000, 23423.25) == (10000 + 23423.25)
```
### [Core/String](/Examples/Core/String.kel)
```ruby
# String concatenation
println "you " & "are " & "a " & "genius!"

println (random()...10 ~ $0 & $1)

# Iterating a stirng
"123456" as @list | $0
assert (("123456" !! @list | $0 ~ $0 & $1) == "123456")

# Replace substring in string
assert replace("I am a pig", "pig", "genius") == "I am a genius"

# Access through subscript
assert "21345"[3] == "4"

# Contains
assert "BadPerson" contains "dP"

# Regex replace
assert regReplace("aaa3aa43aa5aa6aa7aa8","[\d]+","($0)") == "aaa(3)aa(43)aa(5)aa(6)aa(7)aa(8)"
assert regReplace("a\/\3", "\\\\", "\.") == "a./.3"

# Regex matches
assert regMatches("1,2,3","\d") == {"1", "2", "3"}
```
### [Core/Subscript](/Examples/Core/Subscript.kel)
```ruby
println a[b[c][d + f]][g] + m
println a[b][c] + d
println d + [a, b, c]
println [a, b, c] + [d, q, f([a, s, t])] + {u, f([v, w, t])[m][x + z[y]]}

```
### [Core/TrailingClosure](/Examples/Core/TrailingClosure.kel)
```ruby
# Fucking trailing closure syntax!

def l1 = random()...10

# This is equivalent to "l1 | $0 + $1"
println map(l1) {$0 ^ 2}

# This is equivalent to "l1 ~ $0 + $1"
println reduce(l1) {$0 + $1}

# This is equivalent to "l1 |? $0 > 0.5"
println filter(l1) {$0 > 0.5}

# This is equivalent to "l1 >? $0 > 0.5"
println sort(l1) {$0 > $1}
```
### [Core/Variable](/Examples/Core/Variable.kel)
```ruby
# Defining variables
def a = 3
b := 4

assert a + b == 7

# Mutating a variable
a++
b += 1

# a is now 4, b is now 5
println "a is " & a & ", b is " & b

# Inout variable (behaves like reference)
def a = 3
def f(x) {
    x := x^2;
    return x
}

# Prints 9
println f(a)

# Prints 3 - a has not changed
assert a == 3

# Prints 9
println f(&a)

# a is now 9 because the reference operator "&" passes a as an inout variable
assert a == 9

# List all user defined variables
listVars()

# Clear all user defined variables
clearVars()
```
### [LinearAlgebra/Matrix](/Examples/LinearAlgebra/Matrix.kel)
```ruby
# a 2 x 2 matrix
def m2x2 = [[1, 3], [1, 2]]
println m2x2

# Get the element in the second column, second row
println m2x2[1][1]

# 3 dimensional matrix of 3 x 3 x 2
def m3x3x2 = [[[1, 4], [2, 7], [3, 4]], [[1, 4], [2, 7], [3, 4]], [[1, 4], [2, 7], [3, 4]]]

#                                                         ^
# get the highlighted element (prints 3)
println m3x3x2[1][2][0]

# Get the determinant of matrix
println (det [[a, b, c], [x, y, z], [i, q, k]])
println (det [[5, 8, 11], [8, 13, 18], [11, 18, 25]])

# Matrix generation
# Generate a 3 x 3 matrix
println mat(3)

# Generate a 4 x 5 matrix
println mat(4, 5)

# Creating a random 3 x 3 matrix (The syntax is WILD!)
def r_mat = (mat(3) | ($0 | random()))
println r_mat

# Matrix multiplication
println [[1, 2], [2, 3], [3, 4]] ** [[1, 2, 3], [2, 3, 4]] == [[5, 8, 11], [8, 13, 18], [11, 18, 25]]
println [[1, 2, 3], [2, 3, 4]] ** [[1, 2], [2, 3], [3, 4]] == [[14, 20], [20, 29]]

# A * Ia = Ia * A = A
def m1 = [[5, 8, 11], [8, 13, 18], [11, 18, 25]] ** idMat(3)
println m1

# Identity matrix
println idMat(3)

# Transpose matrix
println trans(m1)
println ¡([1, 2, 3] !! @matrix) == [[1], [2], [3]]

# Transformation
# $0 -> element
# $1 -> row
# $2 -> column
assert transform(idMat(5)) {
    $0 + $1 - $2
} == [
    [1, -1, -2, -3, -4],
    [1,  1, -1, -2, -3],
    [2,  1,  1, -1, -2],
    [3,  2,  1,  1, -1],
    [4,  3,  2,  1,  1]
]

# Cofactor of matrix
assert cofactor([
    [1, -1, -2, -3, -4],
    [1,  1, -1, -2, -3],
    [2,  1,  1, -1, -2],
    [3,  2,  1,  1, -1],
    [4,  3,  2,  1,  1]
]) == [
    [21,  21, -12,   3,   6],
    [19,  36,  11,  -7,   3],
    [-8,   9,  41,  11, -12],
    [-3,  -3,   9,  36,  21],
    [14,  -3,  -8,  19,  21]
]
```
### [LinearAlgebra/Vector](/Examples/LinearAlgebra/Vector.kel)
```ruby
# Find the unit vector
println unitVec([a, b, c])

# Find the magnitude of the vector
println mag([a, b, c])

# Dot product
println [a, b] * [c, d]

# Vector addition/subtraction
println [a, b, c] + [d, f, g]

# Angle between 2 vectors
v1 := [1, 3, 5]
v2 := [4, 7, 9]
println angle(v1, v2)
```
### [Misc/Arcane](/Examples/Misc/Arcane.kel)
```ruby
# Create a list {f(3,4), f(3,4), f(3,4), f(3,4), f(3,4)}, then store the list in variable "c"
c:=repeat(f(3,4),5)

# Define f(a,b) = random(a, b) ^ 2
f(a,b):=random(a,b)^2

# Evaluate c, which generate a list of random numbers according to the definition of f.
println(eval c)

# Delete variable c.
del c

# Evaluate c again. You can see now that it no longer has any value.
eval c

# Define a function that generates a 2D matrix consisting of random 0 and 1s of a dimension
def matrix(a) = (round(random())...a...a)

# Set x equal to a list of 5 random integers from 1 to 5
x:=round(random(1,5)) repeat 5
println x

# Set x to the sum of all elements in x
x:=sum(x)
println x

# Store a x by x random matrix into variable m
m:=matrix(x)
del x

# Print the matrix as the second output
println m

# Or, you can do something crazy like this, all on a single line!
def f() = ({1, 2, 3, x} | $0 ^ 2 -> define(f(x), sum($0)); f(12) -> $0...5 | $0 % 7 -> (sum($0)!)° -> define(a, $0 % 12345 / 3 * e); cos(log(a) ^ 2) * √((5!)!) * 360°)
println(f())
del a

# Store a string "Hello World" into variable 'greeting'
def greeting = "Hello World"
println greeting

# Runtime compilation!
eval(compile "println \"Hello World from runtime compilation!\"")

# Factorization
x:=factor(a*b+a*c+2a*f+d*a)
println x
del x

# List operations
println {1, 3, 4} + {log(x), 2, 5 ^ 2}
println (try {1, 2} + {3})

def l1 = {2, 3, 7, x, log(a), g(x)}
def f(x) = x^3 + 3x + 4
println f(l1)
del f

# Combinations and permutations
println(a ncr b)
println(a npr b)

def l1 = ({1, 2, 3, 4, 5, 6} | (9 ncr $0))
println l1

def l1 = {a, b, c, d, f}
print "l1 = "
println l1

println "l1 | $0 + k ~ f($0, $1)"
println(l1 | $0 + k ~ f($0, $1))

def f(a, b) = a + b
println f(a,b)
println (l1 | $0 + k ~ f($0, $1))
println ((x ^ 3)'x << x = 3)
```
### [Misc/DiceRoll](/Examples/Misc/DiceRoll.kel)
```ruby
def dice1() = round random(1,6)
def dice2() = int random(1, 7)

seeds(x) := round random(1, 6) ... x
def dice3() = seeds(10)[int random(0, 9)]

# Roll dice 1 10000 times
rolls1 := dice1()...10000

# Roll dice 2 10000 times
rolls2 := dice2()...10000

# Roll dice 3 10000 times, but only randomly select 1000 values to count
rolls3 := dice3()...1000

# Find the average of the rollings
print "Expected value of dice 1 rolls: "
println mean(rolls1)

print "Expected value of dice 2 rolls: "
println mean(rolls2)

print "Expected value of dice 3 rolls: "
println mean(rolls3)
```
### [Misc/FindBest](/Examples/Misc/FindBest.kel)
```ruby
iq_scale := 180
look_scale := 100

def iq() = random() * iq_scale
def look() = random() * look_scale

# Convert looks and iq to a score out of 100
def score() = round (look() + iq() -> $0 / (iq_scale + look_scale) * 100)


# Define a function gen(x) that generate scores for x people
def gen(x) = score()...x

# Generate two groups of people, each group w/ 5 individuals
def groups = gen(5)...2

# Declare a matrix of names
def names = {{"Henry", "Bob", "George", "Ann", "Marcus"}, {"Ms. Chen", "Bobibuha", "Tadalamaya", "Kabooma", "Delta"}}

# Associate names with scores
l1 := (names::0 | ($0 : groups::0::$1))
l2 := (names::1 | ($0 : groups::1::$1))

println "Group 1: "
println l1
println "Group 2: "
println l2


def find_best_in(group) = (best_person := ("" : 0); group | $0::1 > best_person::1 ? (best_person := $0) : _ ; best_person)

print "Best in group 1: "
println find_best_in(l1)
print "Best in group 2: "
println find_best_in(l2)
```
### [Misc/Greeting](/Examples/Misc/Greeting.kel)
```ruby
println "Please enter your name:"
def name = readLine()
println "Hello, " & name
```
### [Misc/RepeatMapDemo](/Examples/Misc/RepeatMapDemo.kel)
```ruby
# Generate a list containing numbers from 1 to 100, store it into l1
i := 0
l1 := (i := i + 1; i)...100

# Define a function of f in terms of a and b
def f(a, b) = a + b

# Reduce the list using f as a binary function, then store it into x
x := (l1 ~ f($0, $1))

println "l1 = " & l1
println "x  = " & x
```
### [Misc/StatProblem](/Examples/Misc/StatProblem.kel)
```ruby
def airList = {
    7.6, 3.8, 2.1, 3.7, 4.7, 4.9, 5.2, 3.4, 4.1, 2.7, 3.1, 3.8, 3.0, 6.2, 2.0, 1.1, 4.4, 1.4, 4.3,5.5, 4.1, 5.0, 4.8, 3.2, 6.8, 3.1, 2.5, 6.6, 2.2, 2.5, 4.4
}

def nitList = {
    7.2, 2.5, 1.0, 1.6, 1.5, 3.1, 3.5, 3.2, 3.3, 2.2, 3.4, 3.2, 0.9, 3.4, 1.8, 0.7, 4.2, 2.1, 3.0, 3.4, 2.8, 3.4, 3.3, 2.5, 2.7, 1.4, 1.5, 2.2, 2.0, 2.7, 3.7
}
def diff = airList - nitList
def diffStatResult = oneVar(diff)
for (t: diffStatResult) {
    println t
}

def outliers = outliers(diff)[1][1]
println outliers

# Remove outliers
diff := (diff |? !(outliers(diff)[1][1] contains $0))
println diff

# State: where a and n are the mean loss of pressure from air and nitro
# Plan:
#         - Random:
#         - Normal:
#        - Independent:
```
### [Misc/TwoSampleTTest](/Examples/Misc/TwoSampleTTest.kel)
```ruby
input := (split("1 24 25 2 30 31 3 22 23 4 24 24 5 26 27 6 23 25 7 26 28 8 20 20 9 27 27 10 28 30", " ") | $0 as @number)

input := (input |? $0 > 10)
def noCup = (input |? $1 % 2 == 0)
def oneCup = (input |? $1 % 2 == 1)
def diff = oneCup - noCup

for (i: oneVar(diff)) {
    println i
}

def t = 1 / (0.8165 / √(10))
def p = tCdf(t,inf,9)
println "p-value: " & p
```
### [Probability](/Examples/Probability.kel)
```ruby
# nCr, nPr
println (9 ncr 3)
println (9 npr 3)

# Generate a list of all possible unordered combinations of n elements from a list
println ({1, 2, 3, x, a, b, 4, 5} ncr 4)

# Generate a list of all possible permutations of n elements from a list
assert size({a, b, c} npr 3) == 6

# Random number generation
println "Calculating average of 100000 random numbers..."
println mean(random()...100000)

# A function that approaches 1 as x approaches infinity.
def f(x) = min(random()...x) + max(random()...x)
```
### [Statistics/ConfidenceInterval](/Examples/Statistics/ConfidenceInterval.kel)
```ruby
# z interval
a := zInterval(0.5,2,3,0.95)
b := zInterval(0.5,{1,2,3},0.95)
assert round(reduce(a["CI"] - b["CI"]) {$0 + $1}, 5) == 0

# t interval from sample data
c := tInterval({1,2,3,5}, 0.95)
assert round(c["CI"][0], 5) == 0.03247

# t interval from statistics
d := tInterval(5,1,3,0.95)
assert round(d["ME"], 5) == 2.48414

# One proportion z interval
zIntervalOneProp(5,10,0.95) | println($0)

# Two sample z interval from data
zIntervalTwoSamp(5,7,{4,7,2},{8,6,4},0.95) | println($0)

# Two sample z interval from stats
zIntervalTwoSamp(5,7,214,20,195,30,0.95)

# Two sample t interval from stats
def result = tIntervalTwoSamp(20.3,2.1,40,19.2,1.9,40,0.9)
assert round(result["df"], 3) == 77.232
assert round(result["ME"], 3) == 0.745
assert round(result["CI"][0], 3) == 0.355
assert round(result["CI"][1], 3) == 1.845
result | println($0)
```
### [Statistics/Distribution](/Examples/Statistics/Distribution.kel)
```ruby
# Normal cumulative distribution frequency
println normCdf(-inf, 7, 45, 21)
println normCdf(-1, 1)
println normCdf(0)

# One variable statistics
println oneVar(l1)

# Binomial probability distribution
# assert binomPdf(1000, 0.1, 5) == 2.4421153439624504*10^-38
assert geomCdf(0.5, 2, 4) == 0.4375
assert tCdf(-inf, inf, 20) == 1
```
### [Statistics/OneVar](/Examples/Statistics/OneVar.kel)
```ruby
# Five number summary
println (sum5n({1, 3, 7, 9, 11, 12, 17}) | $0::1)

def l1 = {1,1,2,2,3,3,3,4,2,6,9,49,107}
println sum5n(l1)

# Inter-quartile range
println iqr(l1)

# Median
println median(l1)

# Outliers
println outliers(l1)

# Mark -- Distribution
```
### [Statistics/Regression](/Examples/Statistics/Regression.kel)
```ruby
def l1 = {1,2,3,7,9,10}
def l2 = {2,5,7,6,9,10}

def result = linReg(l1,l2)
def definition = result[0][1][1]
def regEq(a) = (definition << x = a)

regEq(3)
assert round(regEq(3) - (3.00909 + 0.654545 * 3), 3) == 0
```
### [SystemCheck](/Examples/SystemCheck.kel)
```ruby
# Run all Kelvin scripts and tests and do a pansystemic performance analysis.

# Replace with your absolute directory to Examples
def examples_dir = "/Users/jiachenren/iCloudDrive (Archive)/Documents/Developer/Kelvin/Examples/"

def start_time = time()
def files = {
    "Misc/Arcane.kel",
    "Misc/DiceRoll.kel",
    "Misc/FindBest.kel",
    "Misc/RepeatMapDemo.kel",
    "Misc/StatProblem.kel",
    "Misc/TwoSampleTTest.kel",
    "Tests.kel",
    "Probability.kel",
    "Algebra/Trigonometry.kel",
    "Algebra/Factor.kel",
    "Algebra/Expand.kel",
    "Algebra/BooleanLogic.kel",
    "Calculus/Differentiation.kel",
    "Calculus/Integration.kel",
    "LinearAlgebra/Vector.kel",
    "LinearAlgebra/Matrix.kel",
    "Statistics/OneVar.kel",
    "Statistics/Distribution.kel",
    "Statistics/Regression.kel",
    "Statistics/ConfidenceInterval.kel"
}

def file_paths = (files | (examples_dir & $0))
file_paths | (run $0)

def core_files = {
    "FlowControl/Conditionals.kel",
    "FlowControl/Loops/WhileLoop.kel",
    "FlowControl/Loops/ForLoop.kel",
    "Benchmarking.kel",
    "ErrorHandling.kel",
    "Debugging/StackTrace.kel",
    "HigherOrderFunction.kel",
    "Function.kel",
    "Variable.kel",
    "List.kel",
    "Multiline.kel",
    "String.kel",
    "RunShell.kel",
    "Subscript.kel",
    "TrailingClosure.kel",
}

for (file: core_files) {
    full_path := examples_dir & "Core/" & file;
    run full_path
}

def alg_files = {
    "BinarySearch.kel",
    "FlatMap.kel",
    "Deconstruct.kel",
    "Contains.kel",
    "Recursion.kel"
}

map(alg_files) {
    run examples_dir & "Algorithms/" & $0
}

println "System check completed in " & (time() - start_time) & " seconds."
```
### [Tests](/Examples/Tests.kel)
```ruby
# Comprehensive test
# true = PASS
# false = FAIL

assert (c := f(3,4)...3; c) == {f(3, 4), f(3, 4), f(3, 4)}
assert (a...2...3) == {{a, a}, {a, a}, {a, a}}
del c

def f() = ({1, 2, 3, x} | $0 ^ 2 -> define(f(x), sum($0)); f(12) -> $0...5 | $0 % 7 -> (sum($0)!)° -> define(a, $0 % 12345 / 3 * e); cos(log(a) ^ 2) * √((5!)!) * 360°)
# assert f() == 3.8082405532548922906*10^99
del f
del a

assert ((1 + (a - 1 - (b - 3)) + 4) == (-1 * b + a + 7))

def bool = ((round random()...5...5)[4][3] -> $0 == 1 || $0 == 0)
assert bool == true

assert ({1, 2, 3} | $0 > 1 ? (true : false)) == {false, true, true}
assert (true && false && b || true || false || d || a) == (true || false && b || d || a)
assert x ^ x * x / x == x ^ x
assert v + d + c + b + a - b - (d - c + a) - a - v == c * 2 + a * -1
assert a ^ x * (0 - a) ^ 3 == a ^ (x + 3) * -1
assert a * a * 4 * 3 == a ^ 2 * 12
assert a * 4 + a * 3 == a * 7
assert (a * 3) ^ 2 == a ^ 2 * 9
assert c + (b + a ^ 2 * 2 + a ^ 2 - b) - a ^ 2 * 3 == c
assert round(cos(12) ^ log(4) % 0.1 + (43 + 33 - 23 * (5 + 47) ^ 2 / 2), 10) == -31019.9971647929
assert ((3!)!)° / 4 / pi == 1
assert 1 + 4 + a - 1 - (b - 3) == a + 7 - b
assert (a || b && true and false || true || d || false) == true
assert x * x ^ x / x == x ^ x
assert a + b + c + d + v - b - (a + d - c) - a - v == 2c - a
assert a ^ x * -a ^ 3 == -(a ^ (x + 3))
assert 3a * 4a == 12a ^ 2
assert 3a + 4a == 7a
assert (3a) ^ 2 == 9a ^ 2
assert 2 * a ^ 2 + a ^ 2 + b - b + c - 3 * a ^ 2 == c
assert (3!)!° / 4 / pi == 1

x:=factor(f * a * 2 + d * a + c * a + b * a)
assert x == (f * 2 + d + c + b) * a
del x

assert {log(x), 2, 5 ^ 2} + {1, 3, 4} == {log(x) + 1, 5, 29}

def l1 = {2, 3, 7, x, log(a), g(x)}
def f(x) = x ^ 3 + x * 3 + 4
assert f(l1) == {8, 27, 343, x ^ 3, log(a) ^ 3, g(x) ^ 3} + {6, 9, 21, x * 3, log(a) * 3, g(x) * 3} + 4
del f
del l1

assert ({1, 2, 3, 4, 5, 6} | (9 ncr $0)) == {9, 36, 84, 126, 126, 84}
assert tan(x) * sec(x) * csc(x) * cos(x) ^ 2 == 1
assert (2 * x * a) ^ 2 == 4 * (x * a) ^ 2
assert (2 ^ x) ^ 3 == 8 ^ x
assert (x ^ 2) ^ 3 == x ^ 6

def x = 100
x += √x
assert x == 110

def a = 0
a++
assert (a += x) == 111
# assert (a := a % 11) == 1
assert !(!true || false) == true
assert (a xor b) == (b && !a || a && !b)
assert (sum5n({1, 3, 7, 9, 11, 12, 17}) | $0::1) == {1, 3, 9, 12, 17}
del a
del b

def l1 = {1, 1, 2, 2, 3, 3, 3, 4, 2, 6, 9, 49, 107}
assert size(l1) == 13

# Test implied multiplicity
assert f1(x) == f1(x)
assert (a)(b)(c-d) == a*b*(c-d)
assert f(b)x == f(b)*x
assert 3x3(a) == 3*x3(a)

# Test replace
del x
assert ((x ^ 3)'x << x = 3) == 27

# Test matrix
assert [[1, 3], [1, 2]][1][1] == 2
assert ({[1]} | $0 as @list) == {{1}}

def mat = [[a, b, c], [x, y, z], [i, q, k]]
assert det mat == (z * q * -1 + y * k) * a + (z * i * -1 + x * k) * b * -1 + (y * i * -1 + x * q) * c

assert [[1, 2], [2, 3], [3, 4]] ** [[1, 2, 3], [2, 3, 4]] == [[5, 8, 11], [8, 13, 18], [11, 18, 25]]
assert [[1, 2, 3], [2, 3, 4]] ** [[1, 2], [2, 3], [3, 4]] == [[14, 20], [20, 29]]
assert mat == mat ** idMat(size(mat))

# Test matrix transposition
assert ¡([1, 2, 3] !! @matrix) == [[1], [2], [3]]

# Test normCdf
assert normCdf(-inf, 7, 45, 21) == 0.035184776966467601333
assert normCdf(-1, 1) == 0.6826894808737367093
assert normCdf(0) == 0.500000000524808641

# Test map, reduce, oneVar, repeat, subscript, and closure arguments
assert round((oneVar(0...1000 | 1 + $1) | $0::1 ~ $1 + $0), 5) == 417671830.49443

# Test list operations
def l1 = {1, 2, 3, 4, 5}

# Concatenation
def l2 = (l1 ++ {6, 7, 8, 9, 10})

# Map
def l3 = (l2 | $0 + $1)

# Filter
def l4 = (l1 |? $0 % 2 == 0)

# Sort
def l5 = (l1 >? $0 > $1)

# Reduce
n := (l2 ~ $0 + $1 ^ 2)

# Remove
l1 := (l1 rm 3)

# Subscript by range
l6 := l1[1, 2]

assert l1 == {1, 2, 3, 5}
assert l2 == {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
assert l3 == {1, 3, 5, 7, 9, 11, 13, 15, 17, 19}
assert l4 == {2, 4}
assert l5 == {5, 4, 3, 2, 1}
assert n == 385
assert l6 == {2}

# Test string concatenation
assert "asdf" & "sdfsdf"[1] == "asdfd"

println "Test completed. No errors identified. System operational."

# Test binomCdf
assert sum(binomPdf(10, 0.1)) == 0.99999999999999999973

# Test inout variables
def f(x) = (return x++)
def a = 3
f(&a)
assert a == 4
```
