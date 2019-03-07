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
    
    // Binary arithmetic operations
    public static let add = "+"
    public static let sub = "-"
    public static let mult = "*"
    public static let div = "/"
    public static let exp = "^"
    public static let mod = "mod"
    
    // Unary arithmetic operations
    public static let log = "log"
    public static let log2 = "log2"
    public static let ln = "ln"
    public static let cos = "cos"
    public static let acos = "acos"
    public static let cosh = "cosh"
    public static let sin = "sin"
    public static let asin = "asin"
    public static let sinh = "sinh"
    public static let tan = "tan"
    public static let atan = "atan"
    public static let tanh = "tanh"
    public static let sec = "sec"
    public static let csc = "csc"
    public static let cot = "cot"
    public static let abs = "abs"
    public static let int = "int"
    public static let round = "round"
    public static let negate = "negate"
    public static let sqrt = "sqrt"
    public static let sign = "sign"
    
    // Distribution
    public static let normCdf = "normCdf"
    public static let normPdf = "normPdf"
    public static let randNorm = "randNorm"
    public static let invNorm = "invNorm"
    public static let binomPdf = "binomPdf"
    public static let binomCdf = "binomCdf"
    public static let geomPdf = "geomPdf"
    public static let geomCdf = "geomCdf"
    public static let tPdf = "tPdf"
    public static let tCdf = "tCdf"
    public static let invT = "invT"
    
    // Confidence intervals
    public static let zInterval = "zInterval"
    public static let tInterval = "tInterval"
    public static let zIntervalOneProp = "zIntervalOneProp"
    public static let zIntervalTwoSamp = "zIntervalTwoSamp"
    public static let tIntervalTwoSamp = "tIntervalTwoSamp"
    
    // One variable stats
    public static let mean = "mean"
    public static let max = "max"
    public static let min = "min"
    public static let sumOfDiffSq = "ssx"
    public static let variance = "variance"
    public static let sum = "sum"
    public static let stdev = "stdev"
    public static let fiveNumberSummary = "sum5n"
    public static let interQuartileRange = "iqr"
    public static let median = "median"
    public static let outliers = "outliers"
    public static let oneVar = "oneVar"
    
    // Two variable statistics
    public static let correlation = "correlation"
    public static let covariance = "covariance"
    public static let twoVar = "twoVar"
    public static let determination = "determination"
    
    // Regression
    public static let linReg = "linReg"
    public static let polyReg = "polyReg"
    
    // List & Pair
    public static let list = "list"
    public static let pair = "pair"
    public static let get = "get"
    public static let map = "map"
    public static let reduce = "reduce"
    public static let filter = "filter"
    public static let append = "append"
    public static let size = "size"
    public static let sort = "sort"
    public static let zip = "zip"
    public static let shuffle = "shuffle"
    public static let remove = "rm"
    public static let contains = "contains"
    public static let reverse = "reverse"
    
    // Calculus
    public static let derivative = "derivative"
    public static let tangent = "tangent"
    public static let implicitDifferentiation = "impDif"
    public static let directionalDifferentiation = "dirDif"
    public static let gradient = "grad"
    public static let numericalIntegration = "nIntegrate"
    
    // Algebra
    public static let factorize = "factor" // Also used for factorizing an integer
    public static let expand = "expand"
    
    // Probability
    public static let random = "random"
    public static let npr = "npr"
    public static let ncr = "ncr"
    public static let factorial = "factorial"
    
    // Boolean logic
    public static let and = "and"
    public static let or = "or"
    public static let xor = "xor"
    public static let not = "not"
    
    // Definition & deletion
    public static let define = "def"
    public static let assign = "assign"
    public static let del = "del"
    
    // Mutating binary function
    public static let increment = "++"
    public static let decrement = "--"
    public static let mutatingAdd = "+="
    public static let mutatingSub = "-="
    public static let mutatingMult = "*="
    public static let mutatingDiv = "/="
    public static let mutatingConcat = "&="
    
    // Developer
    public static let `if` = "if"
    public static let ternaryConditional = "ternary"
    public static let `else` = "else"
    public static let pipe = "pipe"
    public static let evaluateAt = "at"
    public static let `repeat` = "repeat"
    public static let copy = "copy"
    public static let concat = "concat"
    public static let split = "split"
    public static let complexity = "complexity"
    public static let eval = "eval"
    public static let exit = "exit"
    public static let date = "date"
    public static let time = "time"
    public static let delay = "delay"
    public static let run = "run"
    public static let `try` = "try"
    public static let `assert` = "assert"
    public static let measure = "measure"
    public static let compile = "compile"
    public static let print = "print"
    public static let println = "println"
    public static let `return` = "return"
    public static let `continue` = "continue"
    public static let `break` = "break"
    public static let `throw` = "throw"
    public static let `for` = "for"
    public static let `while` = "while"
    public static let `inout` = "inout"
    public static let readLine = "readLine"
    public static let stride = "stride"
    public static let getWorkingDirectory = "getWorkingDir"
    
    // Linear algebra
    public static let dotProduct = "dotP"
    public static let crossProduct = "crossP"
    public static let unitVector = "unitVec"
    public static let magnitude = "mag"
    public static let angleBetween = "angle"
    public static let matrixMultiplication = "mult"
    public static let determinant = "det"
    public static let createMatrix = "mat"
    public static let identityMatrix = "idMat"
    public static let transpose = "trans"
    public static let gaussianElimination = "gausElim"
    public static let transform = "transform"
    public static let cofactor = "cofactor"
    
    // Equality
    public static let equals = "=="
    public static let notEquals = "!="
    
    // Relational
    public static let equates = "="
    public static let greaterThan = ">"
    public static let lessThan = "<"
    public static let greaterThanOrEquals = ">="
    public static let lessThanOrEquals = "<="
    
    // Type system
    public static let `as` = "as"
    public static let `is` = "is"
    
    // Number
    public static let greatestCommonDivisor = "gcd"
    public static let leastCommonMultiple = "lcm"
    public static let degrees = "degrees"
    public static let percent = "pct"
}
