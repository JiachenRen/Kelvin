//
//  Compiler.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/4/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

/**
 * Created by Jiachen on 19/05/2017.
 * Interprets mathematical expressions into nested operations
 */
public class Compiler {
    private static let parentheses = ["(",")"]
    private static let brackets = ["{","}"]
    
    private static var symbols: String {
        let operators = BinOperator.registered
            .keys.reduce(""){$0 + $1}
        return ",(){}'\(operators)"
    }
    
    // &? -> +, - , *, /, ^, etc.
    typealias BinRef = Dictionary<String, BinOperator>
    
    // #? -> node
    typealias NodeRef = Dictionary<String, Node>
    
    public static func compile(_ expr: String) throws -> Node {
        var expr = expr
        
        // Validate the expression
        try validate(expr)
        
        // Remove empty space for ease of processing
        expr.removeAll{$0 == " "}
        
        // Format lists
        while expr.contains("{") {
            expr = replace(expr, "{", "}", "list(", ")")
        }
        
        // Handle negative signs (as opposed to 'minus')
        replace(&expr, of: "(-", with: "(0-")
        replace(&expr, of: ",-", with: ",0-")
        expr = expr.first! == "-" ? "0\(expr)" : expr
        
        format(&expr)
        
        // Convert all binary operations to functions with parameters.
        // i.e. a+b becomes #?(a,b)
        let binOps = compartmentalize(&expr)
        var dict = Dictionary<String, Node>()
        let parent = try resolve(expr, &dict, binOps)
        return parent
    }
    
    private static func resolve(_ expr: String, _ dict: inout NodeRef, _ binOps: BinRef) throws -> Node {
        var expr = expr
        
        while expr.contains("(") {
            let r = innermost(expr, "(", ")")
            var prefixIdx = r.lowerBound
            var hasPrefix = false
            while let b = expr.index(prefixIdx, offsetBy: -1, limitedBy: expr.startIndex) {
                if symbols.contains(expr[b]) {
                    break
                }
                prefixIdx = b
                hasPrefix = true
            }
            let idx1 = expr.index(after: r.lowerBound)
            let idx2 = expr.index(before: r.upperBound)
            
            // Range inside parenthesis
            // A range isn't use here to avoid error caused by upperBound < lowerBound
            let ir = [idx1,idx2]
            
            var node: Node? = nil
            if hasPrefix {
                // In case of definitions like random()
                var name = String(expr[prefixIdx..<r.lowerBound])
                if let bin = binOps[name] {
                    name = bin.name
                }
                
                if ir[0] == r.upperBound {
                    node = try Function(name, [Node]())
                } else {
                    let nested = try resolve(String(expr[ir[0]...ir[1]]), &dict, binOps)
                    if let list = nested as? List {
                        node = try Function(name, list.nodes)
                    } else {
                        node = try Function(name, [nested])
                    }
                }
            } else {
                if ir[0] == r.upperBound {
                    throw CompilerError.syntax(errMsg: "undefined operation '()'")
                }
                node = try resolve(String(expr[ir[0]...ir[1]]), &dict, binOps)
            }
            
            let id = "#\(dict.count)"
            dict[id] = node
            let left = String(expr[expr.startIndex..<prefixIdx])
            let right = String(expr[expr.index(after: r.upperBound)...])
            expr = left + id + right
        }
        
        if expr.contains(",") {
            let nodes = try expr.split(separator: ",")
                .map{String($0)}
                .map{try resolve($0, &dict, binOps)}
            return List(nodes)
        } else if let node = dict[expr] ?? Double(expr) ?? Var(expr) {
            return node
        } else {
            throw CompilerError.illegalArgument(errMsg: expr)
        }
    }
    
    private static func compartmentalize(_ expr: inout String) -> BinRef {
        let operators = BinOperator.registered.values
        let prioritized = operators.sorted{$0.priority < $1.priority}
        
        var segregated = [[BinOperator]]()
        var cur = prioritized[0].priority
        var buf = [BinOperator]()
        prioritized.forEach {
            if $0.priority != cur {
                cur = $0.priority
                segregated.append(buf)
                buf = [BinOperator]()
            }
            buf.append($0)
        }
        segregated.append(buf)
        
        var dict = BinRef()
        for operators in segregated {
            var d = Dictionary<Character, String>()
            operators.forEach {
                let id = "&\(dict.count)"
                dict[id] = $0
                d[Character($0.name)] = id
            }
            parenthesize(&expr, operators.map{Character($0.name)}, d)
        }
        return dict
    }
    
    private static func parenthesize(_ expr: inout String, _ ops: [Character], _ rp: Dictionary<Character, String>) {
        func firstIndex() -> String.Index? {
            var first: String.Index? = nil
            ops.forEach {operator_ in
                if let idx = expr.firstIndex(of: operator_) {
                    if first == nil || idx < first! {
                        first = idx
                    }
                }
            }
            return first
        }
        
        while let idx = firstIndex() {
            let idx_ = expr.index(after: idx)
            let _idx = expr.index(before: idx)
            var left = "", right = ""
            var begin = expr.startIndex, end = expr.endIndex
            let r = binRange(expr, idx)
            
            
            // To the right of binary operator
            if expr[idx_] == "(" {
                end = find(expr, start: idx_, close: ")")!
                right = String(expr[idx_...end])
            } else if expr[idx_] == "{" {
                end = find(expr, start: idx_, close: "}")!
                right = String(expr[idx_...end])
            } else if let p = expr.index(r.upperBound, offsetBy: 1, limitedBy: expr.index(before: expr.endIndex)), expr[p] == "(" {
                end = find(expr, start: p, close: ")")!
                right = String(expr[idx_...end])
            } else {
                let rop = String(expr[idx_...r.upperBound])
                right = rop
                end = r.upperBound
            }
            
            // To the left of binary operator
            if expr[_idx] == ")" {
                begin = find(expr, end: _idx, open: "(")!
                while let b = expr.index(begin, offsetBy: -1, limitedBy: expr.startIndex) {
                    if symbols.contains(expr[b]) {
                        break
                    }
                    begin = b
                }
                left = String(expr[begin..._idx])
            } else if expr[_idx] == "}" {
                begin = find(expr, end: _idx, open: "{")!
                left = String(expr[begin..._idx])
            } else {
                let lop = String(expr[r.lowerBound..._idx])
                left = lop
                begin = r.lowerBound
            }
            
            let rLeft = String(expr[..<begin])
            let rRight = String(expr[expr.index(after: end)...])
            let id = rp[expr[idx]]!
            expr = rLeft + "\(id)(\(left),\(right))" + rRight
        }
    }
    
    private static func replace(_ expr: inout String, of target: String, with replacement: String) {
        expr = expr.replacingOccurrences(of: target, with: replacement)
    }
    
    /**
     Formats the raw String to prepare it for the formulation into a Function instance.
     For instance, the call to formatCoefficients("x+2x^2+3x+4") would return "x+2*x^2+3*x+4"
     PS: "-x" becomes = "(0-x)"
     
     - Parameter expr: the expression to have coefficients and negative sign formatted
     */
    private static func format(_ expr: inout String) {
        
        // Formats 9x to 9*x, 5var to 5*var
        (0...9).map{String($0)}.forEach { digit in
            Var.legalChars.forEach { variable in
                let target = "\(digit)\(variable)"
                let rp = "\(digit)*\(variable)"
                replace(&expr, of: target, with: rp)
            }
        }
        
        // When naturally writing mathematic expressions, we tend to write
        // 3*-x instead of 3*(-x), etc.
        // This corrects the format to make it consistent.
        "(*/^<>".forEach { cand in
            let target = "\(cand)-"
            while expr.contains(target) {
                let r = expr.range(of: target)!
                let minusIdx = expr.index(before: r.upperBound)
                let bin = binRange(expr, minusIdx)
                let extracted = expr[minusIdx...bin.upperBound]
                replace(&expr, of: "\(cand)\(extracted)", with: "\(cand)(0\(extracted))")
            }
        }
    }
    
    private static func binRange(_ segment: String, _ binIdx: String.Index) -> ClosedRange<String.Index> {
        let left = String(segment[..<binIdx])
        let right = String(segment[segment.index(after: binIdx)...])
        
        var beginIdx = left.startIndex
        var endIdx = right.endIndex
        
        symbols.forEach { symbol in
            if let idx = left.lastIndex(of: symbol) {
                if idx > beginIdx {
                    beginIdx = left.index(after: idx)
                }
            }
            if let idx = right.firstIndex(of: symbol) {
                if idx < endIdx {
                    endIdx = idx
                }
            }
        }
        
        // Relocate indices in original expr.
        let lb = segment.index(beginIdx, offsetBy: 0)
        let ub = segment.index(endIdx, offsetBy: left.count)
        
        return lb...ub
    }
    
    /**
     Validate the expression for parenthesis/brackets match, illegal symbols, etc.
     */
    private static func validate(_ expr: String) throws {
        func matches(_ expr: String, _ chars: [String]) -> Bool {
            var count: Int? = nil
            for char in chars {
                let c = Character(char)
                if count == nil {
                    count = num(expr, char: c)
                } else if num(expr, char: c) != count {
                    return false
                }
            }
            return true
        }
        if !matches(expr, parentheses) {
            throw CompilerError.syntax(errMsg: "'()' mismatch in \(expr)")
        } else if !matches(expr, brackets) {
            throw CompilerError.syntax(errMsg: "'{}' mismatch in \(expr)")
        } else if expr.contains("&") || expr.contains("#") {
            throw CompilerError.illegalArgument(errMsg: "Illegal character(s) & and #")
        } else if num(expr, char: "'") % 2 != 0 {
            throw CompilerError.syntax(errMsg: "'' mismatch in \(expr)")
        }
    }
    
    /**
     - Parameters:
        - exp: the expression to be modified
        - open: open bracket symbol
        - close: close bracket symbol
        - rp1: replacement for "open"
        - rp2: replacement for "close"
     - Returns: expression with "open" replaced with "open1" and close replaced with "close1"
     */
    private static func replace(_ exp: String, _ open: Character, _ close: Character, _ rp1: String, _ rp2: String) -> String {
        let r = self.innermost(exp, open, close)
        let idx1 = exp.index(after: r.lowerBound)
        let idx2 = exp.index(after: r.upperBound)
        
        let tmp1 = String(exp[..<r.lowerBound])
        let tmp2 = String(exp[idx1..<r.upperBound])
        let tmp3 = String(exp[idx2...])
        
        return tmp1 + rp1 + tmp2 + rp2 + tmp3
    }
    
    /**
     - Returns: the indices of the innermost opening and the closing parenthesis/brackets
     */
    private static func innermost(_ exp: String, _ open: Character, _ close: Character) -> ClosedRange<String.Index>{
        let closeIdx = exp.firstIndex(of: close)!
        let openIdx = exp[..<closeIdx].lastIndex(of: open)!
        return openIdx...closeIdx
    }
    
    /**
     Call to findMatchingIndex("(56+(34+2))*(32+(13+34+2))",4,')') returns 9
     Call to findMatchingIndex("(56+(34+2))*(32+(13+34+2))",0,')') returns 10
     
     - Parameters:
        - start: the starting index, i.e starting idx of parenthesis/bracket
        - close: the char that completes the parenthesis/bracket together with the char at start idx.
     - Returns: the index at which the parenthesis/bracket terminates
     */
    private static func find(_ expr: String, start: String.Index, close: Character) -> String.Index? {
        let open = expr[start]
        var stacks = 0
        for (idx, c) in expr[start...].enumerated() {
            switch c {
            case open: stacks += 1
            case close: stacks -= 1
            default: break
            }
            if stacks == 0 {
                return expr.index(start, offsetBy: idx)
            }
        }
        return nil
    }
    
    
    /**
     See forward(_:,_:,_:); this does the exact opposite of that.
     - Returns: the index at which the parenthesis/bracket opens
     */
    private static func find(_ expr: String, end: String.Index, open: Character) -> String.Index? {
        let close = expr[end]
        var stacks = 0
        for (idx, c) in expr[...end].enumerated().reversed() {
            switch c {
            case close: stacks += 1
            case open: stacks -= 1
            default: break
            }
            if stacks == 0 {
                return expr.index(expr.startIndex, offsetBy: idx)
            }
        }
        return nil
    }
    
    /**
     - Parameter s: String that is going to be indexed for occurrence of char c
     - Parameter c: char c for num of occurrence.
     - Returns: The number of times that **c** shows up in **s**.
     */
    private static func num(_ s: String, char: Character) -> Int {
        var count = 0
        for c in s {
            if c == char {
                count += 1
            }
        }
        return count;
    }
}

enum CompilerError: Error {
    case illegalArgument(errMsg: String)
    case syntax(errMsg: String)
}
