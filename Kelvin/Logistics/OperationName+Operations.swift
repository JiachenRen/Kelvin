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
    static let add = "+"
    static let sub = "-"
    static let mult = "*"
    static let div = "/"
    static let exp = "^"
    static let mod = "mod"
    
    // Unary arithmetic operations
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
    
    // Two variable statistics
    static let correlation = "correlation"
    static let covariance = "covariance"
    static let twoVar = "twoVar"
    static let determination = "determination"
    
    // Regression
    static let linReg = "linReg"
    static let polyReg = "polyReg"
    
    // List & Pair
    static let list = "list"
    static let pair = "pair"
    static let get = "get"
    static let map = "map"
    static let reduce = "reduce"
    static let filter = "filter"
    static let append = "append"
    static let size = "size"
    static let sort = "sort"
    static let zip = "zip"
    static let shuffle = "shuffle"
    static let remove = "rm"
    static let contains = "contains"
    static let reverse = "reverse"
    
    // Calculus
    static let derivative = "derivative"
    static let tangent = "tangent"
    static let implicitDifferentiation = "impDif"
    static let directionalDifferentiation = "dirDif"
    static let gradient = "grad"
    static let numericalIntegration = "nIntegrate"
    
    // Algebra
    static let factorize = "factor" // Also used for factorizing an integer
    static let expand = "expand"
    
    // Probability
    static let random = "random"
    static let npr = "npr"
    static let ncr = "ncr"
    static let factorial = "factorial"
    
    // Boolean logic
    static let and = "and"
    static let or = "or"
    static let xor = "xor"
    static let not = "not"
    
    // Definition & deletion
    static let define = "def"
    static let assign = "assign"
    static let del = "del"
    
    // Mutating binary function
    static let increment = "++"
    static let decrement = "--"
    static let mutatingAdd = "+="
    static let mutatingSub = "-="
    static let mutatingMult = "*="
    static let mutatingDiv = "/="
    static let mutatingConcat = "&="
    
    // Developer
    static let `if` = "if"
    static let ternaryConditional = "ternary"
    static let `else` = "else"
    static let pipe = "pipe"
    static let evaluateAt = "at"
    static let `repeat` = "repeat"
    static let copy = "copy"
    static let concat = "concat"
    static let split = "split"
    static let complexity = "complexity"
    static let eval = "eval"
    static let exit = "exit"
    static let date = "date"
    static let time = "time"
    static let delay = "delay"
    static let run = "run"
    static let `try` = "try"
    static let `assert` = "assert"
    static let measure = "measure"
    static let compile = "compile"
    static let print = "print"
    static let println = "println"
    static let `return` = "return"
    static let `continue` = "continue"
    static let `break` = "break"
    static let `throw` = "throw"
    static let `for` = "for"
    static let `while` = "while"
    static let `inout` = "inout"
    static let readLine = "readLine"
    static let stride = "stride"
    static let getWorkingDirectory = "getWorkingDir"
    
    // Linear algebra
    static let dotProduct = "dotP"
    static let crossProduct = "crossP"
    static let unitVector = "unitVec"
    static let magnitude = "mag"
    static let angleBetween = "angle"
    static let matrixMultiplication = "mult"
    static let determinant = "det"
    static let createMatrix = "mat"
    static let identityMatrix = "idMat"
    static let transpose = "trans"
    static let gaussianElimination = "gausElim"
    static let transform = "transform"
    static let cofactor = "cofactor"
    
    // Equality
    static let equals = "=="
    static let notEquals = "!="
    
    // Relational
    static let equates = "="
    static let greaterThan = ">"
    static let lessThan = "<"
    static let greaterThanOrEquals = ">="
    static let lessThanOrEquals = "<="
    
    // Type system
    static let `as` = "as"
    static let `is` = "is"
    
    // Number
    static let greatestCommonDivisor = "gcd"
    static let leastCommonMultiple = "lcm"
    static let degrees = "degrees"
    static let percent = "pct"
}
