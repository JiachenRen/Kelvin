#  Examples
This directory contains various examples that demonstrate how to the Kelvin language, from **basic programming capabilities** including _variable/function definition_, _loops_, _if statements_, _error handling_, etc. to powerful **built-in APIs** that carry advanced algebraic operations like _factorization_, _stat calculations_ (normCdf, regression, etc.), _differentiation_, etc. 

## Table of Contents
- Algebra
    - [Trigonometry](/Examples/Algebra/Trigonometry)
    - [Factorization](/Examples/Algebra/Factorization)
- Linear Algebra
    - [Matrix](/Examples/Linear%20Algebra/Matrix)
    - [Vector](/Examples/Linear%20Algebra/Vector)
- Statistics
    - [One variable statistics](/Examples/Statistics/One%20Var)
    - [Distribution](/Examples/Statistics/Distribution)
    - [Regression](/Examples/Statistics/Regression)
    - [Confidence intervals](/Examples/Statistics/Confidence%20Interval)
- Calculus
    - [Differentiation](/Examples/Calculus/Differentiation)
    - [Integration](/Examples/Calculus/Integration)
- Developer
    - Algorithms
        - [Binary search](/Examples/Developer/Algorithms/Binary%20Search)
        - [Deconstruct](/Examples/Developer/Algorithms/Deconstruct)
        - [Recursion](/Examples/Developer/Algorithms/Recursion)
        - [Contains](/Examples/Developer/Algorithms/Contains)
    - [Benchmarking](/Examples/Developer/Benchmarking)
    - [Debugging](/Examples/Developer/Debugging/Stack%20Trace)
    - [Dictionary](/Examples/Developer/Dictionary)
    - [Error handling](/Examples/Developer/Error%20Handling)
    - Flow Control
        - [Conditional statements](/Examples/Developer/Float%20Control/Conditionals)
        - [For loop](/Examples/Developer/Flow%20Control/Loops/For%20Loop)
        - [While loop](/Examples/Developer/Flow%20Control/Loops/While%20Loop)
    - [Function](/Examples/Developer/Function)
    - [IO](/Examples/Developer/IO/IO)
    - [List](/Examples/Developer/List)
    - [Subscript access](/Examples/Developer/Subscript)
    - [Trailing closure syntax](/Examples/Developer/Trailing%20Closure)
    - [Variable](/Examples/Developer/Variable)
    - [Working with string](/Examples/Developer/String)
    
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

def result = whatTheHeckDoesThisDo(1, 3)
assert print(result) == {114, 67}
```

## Using Kelvin with macOS built-in Grapher

You can copy and paste the output from kelvin directly into the built-in `Grapher` to graph it (I plan to build a grapher for kelvin in the future, but right now, to keep the scale of the project under control, I am using the built-in option for simplicity). The following screenshots demonstrate using kelvin to compute a tangent plane, then using `Grapher` to visualize:
    
![Kelvin](/Misc/Screenshots/tangent_plane_kelvin.png)
![Grapher](/Misc/Screenshots/tangent_plane_grapher.png)
