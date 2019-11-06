//
//  String+Operations.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/28/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public typealias OperationName = String

public extension OperationName {
    
    // MARK: - Arithmetic
    
    // Binary operations
    static let add = "add"
    static let minus = "minus"
    static let mult = "mult"
    static let div = "div"
    static let power = "power"
    static let mod = "mod"
    
    // Unary operations
    static let log = "log"
    static let log2 = "log2"
    static let ln = "ln"
    static let cos = "cos"
    static let acos = "acos"
    static let cosh = "cosh"
    static let sin = "sin"
    static let asin = "asin"
    static let sinh = "sinh"
    static let tan = "tan"
    static let atan = "atan"
    static let tanh = "tanh"
    static let sec = "sec"
    static let csc = "csc"
    static let cot = "cot"
    static let abs = "abs"
    static let int = "int"
    static let round = "round"
    static let negate = "negate"
    static let sqrt = "sqrt"
    static let sign = "sign"
    
    // MARK: - Stats
    
    // Distribution
    static let normCdf = "normCdf"
    static let normPdf = "normPdf"
    static let randNorm = "randNorm"
    static let invNorm = "invNorm"
    static let binomPdf = "binomPdf"
    static let binomCdf = "binomCdf"
    static let geomPdf = "geomPdf"
    static let geomCdf = "geomCdf"
    static let tPdf = "tPdf"
    static let tCdf = "tCdf"
    static let invT = "invT"
    
    // Confidence intervals
    static let zInterval = "zInterval"
    static let tInterval = "tInterval"
    static let zIntervalOneProp = "zIntervalOneProp"
    static let zIntervalTwoSamp = "zIntervalTwoSamp"
    static let tIntervalTwoSamp = "tIntervalTwoSamp"
    
    // One variable stats
    static let mean = "mean"
    static let max = "max"
    static let min = "min"
    static let sumOfDiffSq = "ssx"
    static let variance = "variance"
    static let sum = "sum"
    static let stdev = "stdev"
    static let fiveNumberSummary = "sum5n"
    static let interQuartileRange = "iqr"
    static let median = "median"
    static let outliers = "outliers"
    static let oneVar = "oneVar"
    
    // Two variable
    static let correlation = "correlation"
    static let covariance = "covariance"
    static let twoVar = "twoVar"
    static let determination = "determination"
    
    // Regression
    static let linReg = "linReg"
    static let polyReg = "polyReg"
    
    // MARK: - List & Pair
    
    static let list = "list"
    static let pair = "to"
    static let get = "get"
    static let set = "set"
    static let map = "map"
    static let reduce = "reduce"
    static let filter = "filter"
    static let append = "append"
    static let count = "count"
    static let sort = "sort"
    static let zip = "zip"
    static let shuffle = "shuffle"
    static let remove = "rm"
    static let contains = "contains"
    static let reverse = "reverse"
    static let flatten = "flatten"
    
    // MARK: - Calculus
    
    static let derivative = "der"
    static let criticalPoints = "criticalPoints"
    static let tangent = "tangent"
    static let implicitDifferentiation = "impDif"
    static let directionalDifferentiation = "dirDif"
    static let gradient = "grad"
    static let numericalIntegration = "nIntegrate"
    
    // MARK: - Algebra
    
    static let factor = "factor" // Factoring an algebraic expression
    static let expand = "expand"
    static let solve = "solve"
    static let numericalSolve = "nSolve"
    static let coefficients = "coef"
    static let rRoots = "rRoots" // Find rational roots of polynomial
    
    // MARK: - Vector
    
    static let dotProduct = "dotP"
    static let crossProduct = "crossP"
    static let unitVector = "unitVec"
    static let magnitude = "mag"
    static let angleBetween = "angle"
    static let project = "proj"
    static let orthogonalBasis = "orthBasis"
    
    // MARK: - Matrix
    
    static let matrixMultiplication = "matMult"
    static let determinant = "det"
    static let determinantCof = "detCof"
    static let createMatrix = "mat" // mat(dim), mat(rows, cols), mat(list, rows, cols)
    static let identityMatrix = "idMat" // idMat(dim)
    static let transpose = "trans"
    static let gaussianElimination = "gausElim"
    static let ref = "ref"
    static let rref = "rref"
    static let transform = "transform"
    static let cofactor = "cofactor"
    static let adjoint = "adjoint"
    static let inverse = "inv"
    static let characteristicPolynomial = "charPoly"
    static let QRFactorization = "factorizeQR"
    static let rationalEigenValues = "rEigenVals"
    static let leastSquares = "leastSq"
    static let augment = "aug"
    
    // MARK: - Probability
    
    static let random = "random"
    static let randomInt = "randInt"
    static let randomMatrix = "randMat" // randMat(dim), randMat(rows, cols)
    static let randomBool = "randBool"
    static let randomPrime = "randPrime"
    
    // MARK: - Number theory
    
    static let npr = "npr"
    static let ncr = "ncr"
    static let powerset = "powerset"
    static let factorial = "factorial" // Find the factorial of the integer
    static let factorize = "factorize" // Factorizes the integer
    static let primeFactors = "primeFactors" // Prime factors of an integer
    static let factors = "factors" // All natural factors of an integer
    static let isPrime = "isPrime" // Checks if the integer is a prime
    
    // MARK: - Boolean logic
    
    static let and = "and"
    static let or = "or"
    static let xor = "xor"
    static let not = "not"
    static let nor = "nor"
    static let nand = "nand"
    
    // MARK: - Declaration
    
    static let define = "def"
    static let assign = "assign"
    static let del = "del"
    static let increment = "increment"
    static let decrement = "decrement"
    static let addAssign = "addAssign"
    static let minusAssign = "minusAssign"
    static let multAssign = "multAssign"
    static let divAssign = "divAssign"
    static let concatAssign = "concatAssign"
    
    // MARK: - Flow control
    
    static let `if` = "if"
    static let ternaryConditional = "ternary"
    static let `else` = "else"
    static let pipe = "pipe"
    static let invoke = "invoke"
    static let functionRef = "func"
    
    // Loop
    static let `repeat` = "repeat"
    static let copy = "copy"
    static let `for` = "for"
    static let `while` = "while"
    static let `return` = "return"
    static let `continue` = "continue"
    static let `break` = "break"
    static let stride = "stride"
    
    // MARK: - System utilities
    
    static let complexity = "complexity"
    static let eval = "eval"
    static let exit = "exit"
    static let date = "date"
    static let time = "time"
    static let delay = "delay"
    static let run = "run"
    static let `import` = "import"
    static let compile = "compile"
    static let measure = "measure"
    static let listVariables = "listVars"
    static let clearVariables = "clearVars"
    static let listFunctions = "listFuncs"
    static let clearFunctions = "clearFuncs"
    static let runShell = "shell"
    
    // MARK: - IO
    
    static let evaluateAt = "at"
    static let print = "print"
    static let println = "println"
    static let printMat = "printMat"
    static let `inout` = "inout"
    static let readLine = "readLine"
    static let readFile = "readFile"
    static let appendToFile = "appendToFile"
    static let writeToFile = "writeToFile"
    static let pathExists = "pathExists"
    static let isDirectory = "isDir"
    static let removePath = "removePath"
    static let createFile = "createFile"
    static let createDirectory = "createDir"
    static let listPaths = "listPaths"
    static let getWorkingDirectory = "dir"
    static let setWorkingDirectory = "setDir"
    
    // MARK: - Debug & Error
    
    static let setStackTraceEnabled = "setStackTraceEnabled"
    static let printStackTrace = "printStackTrace"
    static let clearStackTrace = "clearStackTrace"
    static let setStackTraceUntracked = "setStackTraceUntracked"
    static let `try` = "try"
    static let `throw` = "throw"
    static let `assert` = "assert"
    static let assertEquals = "assertEquals"
    
    // MARK: - Relational
    
    static let equals = "equals"
    static let notEquals = "neq"
    static let equates = "equates"
    static let greaterThan = "greaterThan"
    static let lessThan = "lessThan"
    static let greaterThanOrEquals = "geq"
    static let lessThanOrEquals = "leq"
    
    // Type system
    static let `as` = "as"
    static let `is` = "is"
    
    // Number
    static let greatestCommonDivisor = "gcd"
    static let leastCommonMultiple = "lcm"
    static let degrees = "degrees"
    static let percent = "pct"
    static let approximateFraction = "frac"
    
    // MARK: - Strings
    
    static let concat = "concat"
    static let split = "split"
    static let replace = "replace"
    static let regexReplace = "regReplace"
    static let regexMatches = "regMatches"
    static let lowercased = "lowercased"
    static let uppercased = "uppercased"
    
    // MARK: - Syntax
    static let `prefix` = "prefix"
    static let `infix` = "infix"
    static let `postfix` = "postfix"
    static let `auto` = "auto"
}
