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
    private static let squareBrackets = ["[", "]"]
    private static let parentheses = ["(", ")"]
    private static let brackets = ["{", "}"]
    
    /// Symbols from binary operators, shorthands, and syntactic sugars.
    private static var symbols: String {
        let operators = Syntax.lexicon
            .keys.reduce(""){"\($0)\($1)"}
        return ",(){}[]'\(operators)"
    }
    
    /// Digits from 0 to 9
    private static var digits = (0...9).reduce(""){"\($0)\($1)"}
    
    /// A dictionary that maps a operator reference to its encoding.
    typealias OperatorReference = Dictionary<String, Syntax.Encoding>
    
    /// A dictionary that maps a node reference to a node value.
    typealias NodeReference = Dictionary<String, Node>
    
    /// Definitions for operation and encodings for operators are loaded once.
    private static var initialized = false
    
    /// Flags are unique unicode codes that are only understood by the compiler.
    private class Flag {
        
        /// Denotes a reference to a node.
        static let node = Syntax.Encoder.next()
        
        /// Denotes a reference to an operator.
        static let `operator` = Syntax.Encoder.next()
    }
    
    /// Used to restore escape characters to their original form
    /// e.g \t becomes a tab.
    private static let escapeCharDict: [String: String] = [
        "\\n": "\n",
        "\\r": "\r",
        "\\t": "\t",
        "\\\"": "\"",
        "\\\\": "\\"
    ]
    
    /**
     Compile a single line expression.
     
     - Parameter expr: String representation of an expression
     - Returns: Parent node of the compiled expression.
     */
    public static func compile(_ expr: String) throws -> Node {
        var expr = expr
        
        // Load definitions before compilation.
        if !initialized {
            Operation.reloadDefinitions()
            Syntax.createDefinitions()
            initialized = true
        }
        
        // Encode strings
        var dict = Dictionary<String, Node>()
        encodeStrings(&expr, dict: &dict)
        
        // Validate the expression
        try validate(expr)
        
        // Format lists and vectors
        while expr.contains("{") {
            expr = replace(expr, "{", "}", "list(", ")")
        }
        
        while expr.contains("[") {
            expr = replace(expr, "[", "]", "vector(", ")")
        }
        
        // Apply syntactic transformations before compilation (encoding)
        Syntax.lexicon.map {$0.value}
            .sorted {$0.compilationPriority > $1.compilationPriority}
            .forEach {expr = applySyntax($0, for: expr)}
        
        // Format the expression for compilation
        format(&expr)
        
        // Convert all binary operations to functions with parameters.
        // i.e. a+b becomes &?(a,b)
        let binOps = binaryToFunction(&expr)
        
        // Construct operation tree
        let parent = try resolve(expr, &dict, binOps)
        
        // Restore encodings to their original form.
        return decode(parent)
    }
    
    /**
     Compile a multi-line document into a program.
     
     - Parameter document: A string containing multiple lines of code
     - Returns: A program.
     */
    public static func compile(document: String) throws -> Program {
        let lines = document.split(separator: "\n", omittingEmptySubsequences: false)
            .map {String($0)}
        var statements = [Node]()
        
        for (i, line) in lines.enumerated() {
            
            // Character '#' serves as a precursor for comment
            // Empty lines are omitted.
            if line.starts(with: "#") || line == "" {
                continue
            }
            
            do {
                let node = try compile(line)
                statements.append(node)
            } catch let e {
                throw CompilerError.error(onLine: i + 1, e)
            }
        }
        
        return Program(statements)
    }
    
    /// Replace strings in the expression w/ node references and store the
    /// actual string values into the node reference dictionary.
    /// They are converted back at the final step of compilation.
    private static func encodeStrings(_ expr: inout String, dict: inout NodeReference) {
        
        // Regex for matching string inside double quotes
        let regex = try! NSRegularExpression(pattern: "([\"'])(\\\\?.)*?\\1", options: NSRegularExpression.Options.caseInsensitive)
        
        var count = 0
        while true {
            let range = NSMakeRange(0, expr.count)
            let rg = regex.rangeOfFirstMatch(in: expr, options: [], range: range)
            
            // No more matches, break the loop.
            if rg.upperBound == Int.max {
                break
            }
            
            var left = ""
            var extracted = ""
            var right = ""
            
            for (i, c) in expr.enumerated() {
                let s = "\(c)"
                if i < rg.lowerBound {
                    left += s
                } else if i == rg.lowerBound || i == rg.upperBound - 1 {
                    continue // Skip left quotation mark
                } else if i < rg.upperBound {
                    extracted += s
                } else {
                    right += s
                }
            }
            
            let encoded = "\(Flag.node)\(count)"
            
            // Updated the expression with the code for the extracted string.
            expr = "\(left)\(encoded)\(right)"
            
            // Restore escape characters to their original form.
            for (key, value) in escapeCharDict {
                extracted = extracted.replacingOccurrences(of: key, with: value)
            }
            
            // Store the extracted string as a node reference
            dict[encoded] = extracted
            
            count += 1
        }
    }
    
    /**
     Perform syntactic manipulations on the expression.
     Replace common names and operators with their encodings.
     
     - Parameters:
        - syntax: The syntax to be applied
        - expr: The string on which the syntax is applied.
     - Returns: The expression w/ the syntax applied.
     */
    private static func applySyntax(_ syntax: Syntax, for expr: String) -> String {
        var expr = expr
        let c = "\(syntax.encoding)"
        let n = syntax.commonName
        
        // Replace operators with their code
        if let o = syntax.operator {
            expr = expr.replacingOccurrences(of: o.name, with: c)
        }
        
        var keyword: String
        
        // Replace infix function names with operator
        switch syntax.position {
        case .prefix:
            // "define a=b" becomes 𑅰a=b
            keyword = "\(n) "
        case .infix:
            // "a and b" becomes "a𑅰b";
            keyword = " \(n) "
        case .postfix:
            // "5 degrees" becomes "5𑅰"
            // "a!" becomes "a𑅰"
            keyword = " \(n)"
        }
        
        return expr.replacingOccurrences(of: keyword, with: c)
    }
    
    /**
     During compilation, all data types are functionalized.
     This restores the functions back to their original data type.
     e.g. list(a,b,c) -> {a,b,c}
          =(a+b, c+x) -> a+b=c+x
     
     - Parameter parent: The parent node to have DTs restored.
     - Returns: The parent node with DTs restored.
     */
    private static func decode(_ parent: Node) -> Node {
        var parent = parent
        
        func name(_ node: Node) -> String? {
            return (node as? Function)?.name
        }
        
        func args(_ node: Node) -> List {
            return (node as! Function).args
        }
        
        // Replace functions generated from syntactic sugars with their
        // corrected names.
        parent = parent.replacing(by: {
            let syntax = Syntax.lexicon[Syntax.Encoding(name($0)!)]!
            return Function(syntax.commonName, args($0))
        }) {
            // If the name of the function is an encoding key,
            // Replace it with its common name.
            if let name = name($0), name.count == 1 {
                return Syntax.lexicon[Syntax.Encoding(name)] != nil
            }
            return false
        }
        
        // Restore list() to {}
        parent = parent.replacing(by: {args($0)}){
            name($0) == "list"
        }
        
        // Restore equations
        parent = parent.replacing(by: {Equation(lhs: args($0)[0], rhs: args($0)[1])}) {
            name($0) == "="
        }
        
        return parent
    }
    
    private static func resolve(_ expr: String, _ dict: inout NodeReference, _ binOps: OperatorReference) throws -> Node {
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
            let ir = [idx1, idx2]
            
            var node: Node? = nil
            if hasPrefix {
                // In case of definitions like random()
                var name = String(expr[prefixIdx..<r.lowerBound])
                if let bin = binOps[name] {
                    name = bin.description
                }
                
                name = removeWhiteSpace(name)
                
                if ir[0] == r.upperBound {
                    node = Function(name, [Node]())
                } else {
                    let nested = try resolve(String(expr[ir[0]...ir[1]]), &dict, binOps)
                    if let list = nested as? List {
                        node = Function(name, list.elements)
                    } else {
                        node = Function(name, [nested])
                    }
                }
            } else {
                if ir[0] == r.upperBound {
                    throw CompilerError.syntax(errMsg: "undefined operation '()'")
                }
                node = try resolve(String(expr[ir[0]...ir[1]]), &dict, binOps)
            }
            
            let id = "\(Flag.node)\(dict.count)"
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
        } else {
            expr = removeWhiteSpace(expr)

            if let node = dict[expr] ?? Int(expr) ?? Double(expr) ?? Bool(expr) {
                return node
            } else {
                return try Variable(expr)
            }
        }
    }
    
    /// Remove trailing and padding white space.
    private static func removeWhiteSpace(_ expr: String) -> String {
        var expr = expr
        // Remove padding white space
        while expr.starts(with: " ") {
            expr.removeFirst()
        }
        
        // Remove trailing white space
        while expr.reversed().first == " " {
            expr.removeLast()
        }
        
        return expr
    }
    
    private static func binaryToFunction(_ expr: inout String) -> OperatorReference {
        let operators = Syntax.lexicon.values
        let prioritized = operators.sorted{$0.priority > $1.priority}
        
        var segregated = [[Syntax.Encoding]]()
        var cur = prioritized[0].priority
        var buf = [Syntax.Encoding]()
        prioritized.forEach {
            if $0.priority != cur {
                cur = $0.priority
                segregated.append(buf)
                buf = [Syntax.Encoding]()
            }
            buf.append($0.encoding)
        }
        segregated.append(buf)
        
        var dict = OperatorReference()
        for operators in segregated {
            var d = Dictionary<Character, String>()
            operators.forEach {
                let id = "\(Flag.operator)\(dict.count)"
                dict[id] = $0
                d[$0] = id
            }
            parenthesize(&expr, operators.map{$0}, d)
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
            var left: String?, right: String?
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
                if idx_ <= r.upperBound {
                    let rop = String(expr[idx_...r.upperBound])
                    right = rop
                }
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
                if r.lowerBound <= _idx {
                    let lop = String(expr[r.lowerBound..._idx])
                    left = lop
                }
                begin = r.lowerBound
            }
            
            let rLeft = String(expr[..<begin])
            let rRight = String(expr[expr.index(after: end)...])
            let id = rp[expr[idx]]!
            
            var args = ""
            if let l = left, let r = right  {
                args = "\(l),\(r)"
            } else if let r = right {
                args = "\(r)"
            } else if let l = left {
                args = "\(l)"
            }
            
            expr = rLeft + "\(id)(\(args))" + rRight
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
        
        // Remove spaces for ease of processing
        expr.removeAll{$0 == " "}
        
        // Add another layer of parenthesis to prevent an error
        expr = "(\(expr))"
        
        // When naturally writing mathematic expressions, we tend to write
        // 3*-x instead of 3*(-x), etc.
        // This corrects the format to make it consistent.
        let candidates = "([*/^<>,".map {Syntax.glossary[String($0)]?.encoding ?? $0}
        for c in candidates {
            let target = "\(c)\(Syntax.glossary["-"]!.encoding)"
            while expr.contains(target) {
                let r = expr.range(of: target)!
                let m = expr.index(before: r.upperBound)
                let bin = binRange(expr, m)
                let e = expr[m...bin.upperBound]
                replace(&expr, of: "\(c)\(e)", with: "\(c)(0\(e))")
            }
        }
        
        func fixCoefficientShorthand(_ symbol: Character, _ digit: Character) {
            let indices = findIndices(of: "\(symbol)\(digit)", in: expr)
            for i in indices {
                var a = expr.index(after: i)
                let limit = expr.index(before: expr.endIndex)
                while let b = expr.index(a, offsetBy: 1, limitedBy: limit) {
                    a = b
                    let ch = String(expr[a])
                    if "\(Variable.legalChars)(".contains(ch) {
                        expr.insert(Syntax.glossary["*"]!.encoding, at: a)
                        break
                    } else if !"\(digits).".contains(ch) {
                        break
                    }
                }
            }
        }
        
        // Fix shorthand syntax of variable coefficients.
        // This can be really tricky:
        // "f1()" should be seen as a function whereas "3(x)" should be seen as "3*x"
        // "arg3er" should be seen as "arg3*er"
        // "3a*4x" should be converted to "3*a*4*x"
        symbols.forEach{s in digits.forEach {fixCoefficientShorthand(s, $0)}}
    }
    
    /**
     Find all indices in which the substring occurs in the given string
     
     - Parameter substr: A string to look for in str
     - Parameter str: A string containing multiple (or none) occurences of substr
     - Returns: The indices at which substr occurs in str.
     */
    private static func findIndices(of substr: String, in str: String) -> [String.Index] {
        var indices = [String.Index]()
        if let r = str.range(of: substr) {
            indices.append(r.lowerBound)
            let left = str[...r.lowerBound]
            let right = String(str[str.index(after: r.lowerBound)...])
            let subIndices = findIndices(of: substr, in: right)
            indices.append(contentsOf: subIndices.map{str.index($0, offsetBy: left.count)})
        }
        return indices
    }
    
    private static func binRange(_ segment: String, _ binIdx: String.Index) -> ClosedRange<String.Index> {
        let left = String(segment[..<binIdx])
        let right = String(segment[segment.index(after: binIdx)...])
        
        var beginIdx = left.startIndex
        var endIdx = right.endIndex
        
        symbols.forEach {(symbol: Character) in
            if let idx = left.lastIndex(of: symbol) {
                if idx >= beginIdx {
                    beginIdx = left.index(after: idx)
                }
            }
            if let idx = right.firstIndex(of: symbol) {
                if idx <= endIdx {
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
            throw CompilerError.syntax(errMsg: "() mismatch in \(expr)")
        } else if !matches(expr, brackets) {
            throw CompilerError.syntax(errMsg: "{} mismatch in \(expr)")
        } else if !matches(expr, squareBrackets) {
            throw CompilerError.syntax(errMsg: "[] mismatch in \(expr)")
        } else if expr == "" {
            throw CompilerError.illegalArgument(errMsg: "Give me some juice!")
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

