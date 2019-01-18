//
//  Operator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/9/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

typealias Definition = ([Node]) -> Node?

/// Numerical unary operation
typealias NUnary = (Double) -> Double

/// Numerical binary operation
typealias NBinary = (Double, Double) -> Double

public class Operation: Equatable {

    /// Registered operations are resolved dynamically during runtime
    /// and assigned to functions with matching signature as definitions.
    public static var registered: [Operation] = {
        defaultOperations
    }()

    /// Use this dictionary to assign special attributes to operations.
    /// e.g. since + and * are commutative, the "commutative" flag should be assigned to them.
    public static var configuration: [Attribute: [String]] = {
        defaultConfiguration
    }()

    /// A value that represents the scope of the signature
    /// The larger the scope, the more universally applicable the function.
    public var scope: Int {
        return signature.reduce(0) {
            $0 + $1.rawValue
        }
    }

    let def: Definition
    let name: String
    let signature: [ArgumentType]

    init(_ name: String, _ signature: [ArgumentType], definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
    }

    /// Register the parametric operation.
    public static func register(_ operation: Operation) {
        registered.append(operation)
    }

    /// Clear the existing registered operations, then
    /// load the default definitions and configurations from Definitions.swift
    public static func restoreDefault() {

        // Restore to default configuration
        self.configuration = defaultConfiguration

        // Clear existing registrations
        registered = defaultOperations
    }

    /**
     Remove a parametric operation from registration.
     
     - Parameters:
     - name: The name of the operation to be removed.
     - signature: The signature of the operation to be removed.
     */
    static func remove(_ name: String, _ signature: [ArgumentType]) {
        let parOp = Operation(name, signature) { _ in
            nil
        }
        registered.removeAll {
            $0 == parOp
        }
    }

    /// Remove the parametric operations with the given name.
    /// - Parameter name: The name of the operations to be removed.
    static func remove(_ name: String) {
        registered.removeAll {
            $0.name == name
        }
    }

    /**
     Resolves the corresponding parametric operation based on the name and provided arguments.
     
     - Parameter name: The name of the operation
     - Parameter args: The arguments supplied to the operation
     - Returns: A list of operations with matching signature, sorted in order of increasing scope.
     */
    public static func resolve(_ name: String, args: [Node]) -> [Operation] {
        let candidates = registered.filter {
                    $0.name == name
                }
                // Operations with the smaller scope should be prioritized.
                .sorted {
                    $0.scope < $1.scope
                }

        var matching = [Operation]()

        candLoop: for cand in candidates {
            var signature = cand.signature

            // Deal w/ function signature types that allow any # of args.
            if let first = signature.first {
                switch first {
                case .multivariate where args.count <= 1:
                    break candLoop
                case .multivariate:
                    fallthrough
                case .universal:
                    signature = [ArgumentType](repeating: .any, count: args.count)
                case .numbers:
                    signature = [ArgumentType](repeating: .number, count: args.count)
                case .booleans:
                    signature = [ArgumentType](repeating: .bool, count: args.count)
                default: break
                }
            }

            // Bail out if # of parameters does not match # of args.
            if signature.count != args.count {
                continue
            }

            // Make sure that each parameter is the required type
            for i in 0..<signature.count {
                let argType = signature[i]
                let arg = args[i]
                switch argType {
                case .any:
                    continue
                case .var where !(arg is Variable):
                    fallthrough
                case .bool where !(arg is Bool):
                    fallthrough
                case .list where !(arg is List):
                    fallthrough
                case .number where !(arg is NSNumber):
                    fallthrough
                case .nan where arg is NSNumber:
                    fallthrough
                case .equation where !(arg is Equation):
                    fallthrough
                case .string where !(arg is String):
                    fallthrough
                case .func where !(arg is Function):
                    continue candLoop
                default: continue
                }
            }

            matching.append(cand)
        }

        return matching
    }

    /**
     Commutatively simplify a list of arguments.
     Suppose we have an expression, 1 + a + negate(1) + negate(a);
     First, we check if 1 + a is simplifiable, in this case no.
     Then, we check if 1 + negate(1) is simplifiable, if so,
     simplify and put them back into the pool. At this point,
     we have "a + negate(a) + 0", which then easily simplifies to 0.
     
     - Parameter nodes: The list of nodes to be commutatively simplified.
     - Parameter fun: A function that performs binary simplification.
     - Returns: A node resulting from the simplification.
     */
    public static func simplifyCommutatively(_ nodes: [Node], by fun: String) -> Node {
        var nodes = nodes

        func simplifyBidirectionally(_ nodes: [Node]) -> Node? {
            // Make sure we are only taking in 2 arguments
            assert(nodes.count == 2)
            let forward = Function(fun, [nodes[0], nodes[1]])
            let backward = Function(fun, [nodes[1], nodes[0]])

            let originals = [forward, backward]

            // Simplification could be forward or backward; in that case,
            // perform simplification for both ways and compare them.
            for bin in originals {
                let simplified = bin.simplify()

                // If the junction of i and j can be simplified...
                if simplified.complexity < bin.complexity {
                    return simplified
                }
            }

            return nil
        }

        if nodes.count == 2 {

            // Reverse the order of arguments and simplify again!
            return Function(fun, nodes.reversed()).simplify()
        }

        for i in 0..<nodes.count - 1 {
            let n = nodes.remove(at: i)
            for j in i..<nodes.count {
                if let simplified = simplifyBidirectionally([nodes[j], n]) {
                    nodes.remove(at: j)
                    nodes.append(simplified)

                    // Commutatively simplify the updated list of nodes
                    return simplifyCommutatively(nodes, by: fun)
                }
            }

            // Can't perform simplification w/ current node.
            // Insert it back in and move on to the next.
            nodes.insert(n, at: i)
        }

        // Fully simplified. Reconstruct commutative operation and return.
        return Function(fun, nodes)
    }
    
    
    /// Factorizes the parent node; e.g. a*b+a*c becomes a*(b+c)
    public static func factorize(_ parent: Node) -> Node {
        return parent.replacing(by: {
            factorize(($0 as! Function).args.elements)
        }) {
            ($0 as? Function)?.name == "+"
        }
    }

    /**
     - Todo: Return the simplest form of factorization.
     - Parameter nodes: The arguments of a summation function
     - Returns: The factorized form of arguments.
     */
    public static func factorize(_ nodes: [Node]) -> Node {
        var nodes = nodes
        let factors = commonFactors(nodes)
        for f in factors {
            nodes = nodes.map {
                factorize($0, by: f)
            }
        }
        return **factors * ++nodes
    }
    
    /**
     Factorizes a node by a given factor.
     
     - Note: This function assumes that the relationship b/w node and factor is addition.
     - Parameters:
        - node: The node to be factorized with factor
        - factor: The factor used to factorize the node.
     - Returns: Given node with factor factorized out.
     */
    private static func factorize(_ node: Node, by factor: Node) -> Node {
        if node === factor {
            return 1
        }
        var mult = node as! Function
        assert(mult.name == "*")
        
        var elements = mult.args.elements
        for (i, e) in elements.enumerated() {
            if e === factor {
                elements.remove(at: i)
                break
            }
        }
        
        return **elements
    }

    /**
     Find the common terms of nodes in terms of multiplication.
     It is assumed that the relationship b/w nodes is addition.
     
     - Note: 1 is not returned as a common factor.
     - Parameter nodes: The nodes from which common terms are derived.
     - Returns: Common factors of nodes excluding 1.
     */
    public static func commonFactors(_ nodes: [Node]) -> [Node] {
        var nodes = nodes
        
        // Base case
        if nodes.count == 0 {
            return []
        } else if nodes.count == 1 {
            return nodes
        }

        // Deconstruct a node into its arguments if it is "*"
        // For nodes other than "*", return the node itself.
        func deconstruct(_ node: Node) -> [Node] {
            if let mult = node as? Function, mult.name == "*" {
                return mult.args.elements
            }
            return [node]
        }
        
        // Common terms
        var common = [Node]()

        // Remove the first node from the list
        let node = nodes.removeFirst()
        
        // If any of the nodes are 1, then the expression is not factorizable.
        // e.g. a*b*c + 1 + b*c*d is not factorizable and will eventually cause stack overflow.
        if node === 1 {
            return []
        }
        
        // Deconstruct the node into its operands(arguments)
        let operands = deconstruct(node)
        
        // For each operand of the "*" node, check if it is present in
        // all of the other nodes.
        for o in operands {
            var isCommon = true
            for n in nodes {
                let isFactor = (n as? Function)?.name == "*" && n.contains(where: { $0 === o }, depth: 1)
                
                // If one of the remaining nodes is not 'o' and does not contain 'o',
                // we know that 'o' is not a common factor. Immediately exit the loop.
                if !(isFactor || n === o) {
                    isCommon = false
                    break
                }
            }
            
            // If 'o' is a common factor, then we add 'o' to the common factor array,
            // then factorize each term by 'o', and recursively factor what remains
            // to find the rest of the factors.
            if isCommon {
                common.append(o)
                nodes.insert(node, at: 0)
                
                // Factorize each node with 'o'
                let remaining = nodes.map {factorize($0, by: o)}
                
                // Find common terms of the remaining nodes, recursively.
                let c = commonFactors(remaining)
                common.append(contentsOf: c)
                return common
            }
        }
        
        // If none of the operands in the first node is factorizable,
        // then the expression itself is not factorizable.
        return []
    }

    /**
     - Parameters:
        - name: The name of the function
        - attr: The attribute in question such as .commutative
     - Returns: Whether the function w/ the given name has the designated attribute
     */
    public static func has(attr: Attribute, _ name: String) -> Bool {
        return configuration[attr]!.contains(name)
    }

    /**
     Two parametric operations are equal to each other if they have the same name
     and the same signature
     */
    public static func ==(lhs: Operation, rhs: Operation) -> Bool {
        return lhs.name == rhs.name && lhs.signature == rhs.signature
    }

    /**
     This enum is used to represent the type of the arguments.
     By giving a function a name, the number of arguments,
     and the types of arguments, we can generate a unique signature
     that is used later to find definitions.
     */
    enum ArgumentType: Int, Equatable {
        case number = 0
        case nan = 1
        case `var` = 2
        case `func` = 3
        case bool = 4
        case list = 5
        case equation = 6
        case string = 7
        case any = 100
        case numbers = 1000
        case booleans = 1001
        case multivariate = 4000 // Takes in more than 1 argument
        case universal = 10000 // Takes in any # of args.
    }

    /// Flags that denote special attributes for certain operations.
    public enum Attribute: Hashable {

        /// Debugging and flow control functions like "complexity" and "repeat"
        /// should not simplify args before their execution.
        case preservesArguments

        /// Addition, multiplication, and boolean logic are all commutative
        /// Commutative functions with the same name should only be marked once.
        case commutative

        /// Operations with this flag are only commutative in the forward direction.
        /// e.g. division and subtraction.
        case forwardCommutative
    }

    /**
     Default operation configurations
     */
    public static let defaultConfiguration: [Attribute: [String]] = [
        .commutative: [
            "*",
            "+",
            "and",
            "or"
        ],
        .preservesArguments: [
            "complexity",
            "repeat",
            "feed",
            "exec",
            "define",
            "def",
            "del"
        ],
        .forwardCommutative: [
            "/",
            "-"
        ]
    ]

    /**
     Pre-defined operations with signatures that are resolved and assigned
     to function definitions during compilation.
     */
    public static let defaultOperations: [Operation] = [

        // Basic binary arithmetic
        .init("+", [.number, .number]) {
            bin($0, +)
        },
        .init("+", [.any, .any]) {
            $0[0] === $0[1] ? 2 * $0[0] : nil
        },
        .init("+", [.number, .nan]) {
            $0[0] === 0 ? $0[1] : nil
        },
        .init("+", [.any, .func]) {
            let fun = $0[1] as! Function
            switch fun.name {
            case "*":
                var args = fun.args.elements
                for (i, arg) in args.enumerated() {
                    if arg === $0[0] {
                        let a = args.remove(at: i)
                        if args.count != 1 {
                            continue
                        }
                        let n = args[0] + 1
                        let s = n.simplify()
                        if s.complexity < n.complexity {
                            return s * $0[0]
                        } else {
                            return nil
                        }
                    }
                }
            default: break
            }
            return nil
        },
        .init("+", [.func, .func]) {
            let f1 = $0[0] as! Function
            let f2 = $0[1] as! Function

            if f1.name == f2.name {
                switch f1.name {
                case "*":
                    let (n1, r1) = f1.args.split(by: isNumber)
                    let (n2, r2) = f2.args.split(by: isNumber)
                    if **r1 === **r2 {
                        return **r1 * (**n1 + **n2)
                    }
                default:
                    break
                }
            }

            return nil
        },
        .init("+", [.list, .list]) {
            join(by: "+", $0[0], $0[1])
        },
        .init("+", [.list, .any]) {
            map(by: "+", $0[0], $0[1])
        },

        .init("-", [.number, .number]) {
            bin($0, -)
        },
        .init("-", [.any, .any]) {
            if $0[0] === $0[1] {
                return 0
            }
            return $0[0] + -$0[1]
        },
        .init("-", [.any]) {
            -1 * $0[0]
        },
        .init("-", [.list, .list]) {
            join(by: "-", $0[0], $0[1])
        },
        .init("-", [.list, .any]) {
            map(by: "-", $0[0], $0[1])
        },

        .init("*", [.number, .number]) {
            bin($0, *)
        },
        .init("*", [.var, .var]) {
            $0[0] === $0[1] ? $0[0] ^ 2 : nil
        },
        .init("*", [.var, .func]) {
            let fun = $0[1] as! Function
            let v = $0[0] as! Variable
            switch fun.name {
            case "^" where fun.args[0] === v:
                return v ^ (fun.args[1] + 1)
            default:
                break
            }
            return nil
        },
        .init("*", [.func, .func]) {
            let f1 = $0[0] as! Function
            let f2 = $0[1] as! Function

            if f1.name == f2.name {
                switch f1.name {
                case "^" where f1.args[0] === f2.args[0]:
                    return f1.args[0] ^ (f1.args[1] + f2.args[1])
                default:
                    break
                }
            }
            return nil
        },
        .init("*", [.any, .number]) {
            let n = $0[1] as! NSNumber
            switch n {
            case 0:
                return 0
            case 1:
                return $0[0]
            default:
                return nil
            }
        },
        .init("*", [.list, .list]) {
            join(by: "*", $0[0], $0[1])
        },
        .init("*", [.list, .any]) {
            map(by: "*", $0[0], $0[1])
        },

        .init("/", [.number, .number]) {
            bin($0, /)
        },
        .init("/", [.any, .any]) {
            if $0[0] === $0[1] {
                return 1
            }
            return $0[0] * ($0[1] ^ -1)
        },
        .init("/", [.list, .list]) {
            join(by: "/", $0[0], $0[1])
        },
        .init("/", [.list, .any]) {
            map(by: "/", $0[0], $0[1])
        },

        .init("mod", [.number, .number]) {
            bin($0, %)
        },
        .init("mod", [.list, .list]) {
            join(by: "mod", $0[0], $0[1])
        },
        .init("mod", [.list, .any]) {
            map(by: "mod", $0[0], $0[1])
        },
        
        .init("^", [.number, .number]) {
            bin($0, pow)
        },
        .init("^", [.nan, .number]) {
            if let n = $0[1] as? Int {
                switch n {
                case 0: return 1
                case 1: return $0[0]
                default: break
                }
            }
            return nil
        },
        .init("^", [.number, .nan]) {
            $0[0] === 0 ? 0 : nil
        },
        .init("^", [.func, .number]) {
            let fun = $0[0] as! Function
            switch fun.name {
            case "*":
                if fun.contains(where: isNumber, depth: 1) {
                    let (nums, nans) = fun.args.split(by: isNumber)
                    return (**nums ^ $0[1]) * (**nans ^ $0[1])
                }
            default: break
            }
            return nil
        },
        .init("^", [.number, .func]) {
            let fun = $0[1] as! Function
            switch fun.name {
            case "*" where fun.args.contains(where: isNumber, depth: 1):
                let (nums, nans) = fun.args.split(by: isNumber)
                return ($0[0] ^ **nums) * ($0[0] ^ **nans)
            default: break
            }
            return nil
        },
        .init("^", [.list, .list]) {
            join(by: "^", $0[0], $0[1])
        },
        .init("^", [.list, .any]) {
            map(by: "^", $0[0], $0[1])
        },


        // Basic unary transcendental functions
        .init("log", [.number]) {
            u($0, log10)
        },
        .init("log2", [.number]) {
            u($0, log2)
        },
        .init("ln", [.number]) {
            u($0, log)
        },
        .init("cos", [.number]) {
            u($0, cos)
        },
        .init("sin", [.number]) {
            u($0, sin)
        },
        .init("tan", [.number]) {
            u($0, tan)
        },
        .init("int", [.number]) {
            u($0, floor)
        },
        .init("round", [.number]) {
            u($0, round)
        },
        .init("negate", [.number]) {
            u($0, -)
        },
        .init("negate", [.func]) {
            var fun = $0[0] as! Function
            switch fun.name {
            case "nagate":
                return fun.args[0]
            case "+":
                fun.args.elements = fun.args.elements.map {
                    $0 * -1
                }
                return fun.flatten()
            case "*":
                var args = fun.args.elements
                args.append(-1)
                return *args
            default: break
            }
            return nil
        },
        .init("negate", [.var]) {
            $0[0] * -1
        },
        .init("sqrt", [.number]) {
            u($0, sqrt)
        },

        // Postfix operations
        .init("degrees", [.any]) {
            $0[0] / 180 * V("pi")
        },
        .init("factorial", [.number]) {
            if let i = Int(exactly: $0[0].evaluated!.doubleValue) {
                return factorial(Double(i))
            }
            return "can only perform factorial on an integer"
        },
        .init("pct", [.any]) {
            $0[0] / 100
        },

        // Equality, inequality, and equations
        .init("=", [.any, .any]) {
            Equation(lhs: $0[0], rhs: $0[1])
        },
        .init("<", [.any, .any]) {
            Equation(lhs: $0[0], rhs: $0[1], mode: .lessThan)
        },
        .init(">", [.any, .any]) {
            Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThan)
        },
        .init(">=", [.any, .any]) {
            Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThanOrEquals)
        },
        .init("<=", [.any, .any]) {
            Equation(lhs: $0[0], rhs: $0[1], mode: .lessThanOrEquals)
        },
        .init("equals", [.any, .any]) {
            $0[0] === $0[1]
        },

        // Boolean logic and, or
        .init("and", [.bool, .bool]) { nodes in
            nodes.map {
                        $0 as! Bool
                    }
                    .reduce(true) {
                        $0 && $1
                    }
        },
        .init("or", [.bool, .bool]) { nodes in
            nodes.map {
                        $0 as! Bool
                    }
                    .reduce(false) {
                        $0 || $1
                    }
        },

        // Variable/function definition and deletion
        .init("def", [.equation]) { nodes in
            if let err = (nodes[0] as? Equation)?.define() {
                return err
            }
            return "done"
        },
        .init("define", [.any, .any]) { nodes in
            return Function("def", [Equation(lhs: nodes[0], rhs: nodes[1])])
        },
        .init("del", [.var]) { nodes in
            if let v = nodes[0] as? Variable {
                Variable.delete(v.name)
                Operation.remove(v.name)
                return "deleted '\(v.stringified)'"
            }
            return nil
        },

        // Summation
        .init("sum", [.list]) { nodes in
            return ++(nodes[0] as! List).elements
        },
        .init("sum", [.universal]) { nodes in
            return ++nodes
        },

        // Random number generation
        .init("random", []) { nodes in
            return Double.random(in: 0...1)
        },
        .init("random", [.number, .number]) { nodes in
            let lb = nodes[0].evaluated!.doubleValue
            let ub = nodes[1].evaluated!.doubleValue
            return Double.random(in: lb...ub)
        },
        
        // Algebraic manipulation (factorization, expansion)
        .init("factor", [.any]) {
            factorize($0[0])
        },

        // List related operations
        .init("list", [.universal]) {
            List($0)
        },
        .init("get", [.list, .number]) { nodes in
            let list = nodes[0] as! List
            let idx = Int(nodes[1].evaluated!.doubleValue)
            if idx >= list.count {
                return "error: index out of bounds"
            } else {
                return list[idx]
            }
        },
        .init("size", [.list]) {
            return ($0[0] as! List).count
        },
        .init("map", [.list, .any]) { nodes in
            let list = nodes[0] as! List
            let updated = list.elements.enumerated().map { (idx, e) in
                nodes[1].replacingAnonymousArgs(with: [e, idx])
            }
            return List(updated)
        },
        .init("reduce", [.list, .any]) { nodes in
            let list = nodes[0] as! List
            let reduced = list.elements.reduce(nil) { (e1, e2) -> Node in
                if e1 == nil {
                    return e2
                }
                return nodes[1].replacingAnonymousArgs(with: [e1!, e2])
            }
            return reduced ?? List([])
        },

        // Statistics
        .init("avg", [.list]) { nodes in
            let l = (nodes[0] as! List).elements
            return ++l / l.count
        },
        .init("avg", [.universal]) { nodes in
            return ++nodes / nodes.count
        },
        .init("ssx", [.list]) {
            return ssx($0[0] as! List)
        },
        .init("sample_variance", [.list]) {
            let list = $0[0] as! List
            let s = ssx(list)
            guard let n = s as? Double else {
                // If we cannot calculate sum of difference squared,
                // return the error message.
                return s
            }
            
            return n / (list.count - 1)
        },
        .init("population_variance", [.list]) {
            let list = $0[0] as! List
            let s = ssx(list)
            guard let n = s as? Double else {
                return s
            }
            
            return n / list.count
        },
        .init("sample_stdev", [.list]) {
            return √Function("sample_variance", $0)
        },
        .init("population_stdev", [.list]) {
            return √Function("population_variance", $0)
        },
        
        // Combination and permutation
        .init("npr", [.any, .any]) {
            return $0[0]~! / ($0[0] - $0[1])~!
        },
        .init("ncr", [.any, .any]) {
            return Function("npr", $0) / $0[1]~!
        },

        // Consecutive execution, feed forward, flow control
        .init("then", [.universal]) { nodes in
            return nodes.map {
                $0.simplify()
            }.last
        },
        .init("feed", [.any, .any]) { nodes in
            let simplified = nodes[0].simplify()
            return nodes.last!.replacingAnonymousArgs(with: [simplified])
        },
        .init("repeat", [.any, .number]) { nodes in
            let times = Int(nodes[1].evaluated!.doubleValue)
            var elements = [Node]()
            (0..<times).forEach { _ in
                elements.append(nodes[0])
            }
            return List(elements)
        },
        .init("copy", [.any, .number]) { nodes in
            return Function("repeat", nodes)
        },

        // Developer/debug functions, program input/output, compilation
        .init("complexity", [.any]) {
            $0[0].complexity
        },
        .init("eval", [.any]) {
            return $0[0].simplify()
        },
        .init("exit", []) { _ in
            exit(0)
        },
        .init("compile", [.string]) {
            do {
                return try Compiler.compile($0[0] as! String)
            } catch CompilerError.illegalArgument(let msg) {
                return "ERR >>> illegal argument: \(msg)"
            } catch CompilerError.syntax(let msg) {
                return "ERR >>> syntax: \(msg)"
            } catch {
                return "ERR >>> unknown error"
            }
        },
    ]
}

fileprivate let isNumber: PUnary = {
    $0 is NSNumber
}

fileprivate func join(by bin: String, _ l1: Node, _ l2: Node) -> Node {
    let l1 = l1 as! List
    let l2 = l2 as! List
    
    if l1.count != l2.count {
        return "list dimension mismatch"
    }
    
    return l1.join(with: l2, by: bin)
}

fileprivate func map(by bin: String, _ l: Node, _ n: Node) -> Node {
    let l = l as! List
    
    let elements = l.elements.map {Function(bin, [$0, n])}
    return List(elements)
    
}

fileprivate func V(_ n: String) -> Variable {
    return try! Variable(n)
}

fileprivate func bin(_ nodes: [Node], _ binary: NBinary) -> Double {
    return nodes.map {
                $0.evaluated?.doubleValue ?? .nan
            }
            .reduce(nil) {
                $0 == nil ? $1 : binary($0!, $1)
            }!
}

fileprivate func u(_ nodes: [Node], _ unary: NUnary) -> Double {
    return unary(nodes[0].evaluated?.doubleValue ?? .nan)
}

fileprivate func log10(_ a: Double) -> Double {
    return log(a) / log(10)
}

fileprivate func %(_ a: Double, _ b: Double) -> Double {
    return a.truncatingRemainder(dividingBy: b)
}

/// A very concise definition of factorial.
fileprivate func factorial(_ n: Double) -> Double {
    return n < 0 ? .nan : n == 0 ? 1 : n * factorial(n - 1)
}

/// Sum of difference squared.
fileprivate func ssx(_ list: List) -> Node {
    let nodes = list.elements
    for e in nodes {
        if !(e is NSNumber) {
            return "every element in the list must be a number."
        }
    }
    
    let numbers: [Double] = nodes.map{$0.evaluated!.doubleValue}
    
    // Calculate avg.
    let sum: Double = numbers.reduce(0) {$0 + $1}
    let avg: Double = sum / Double(nodes.count)
    
    // Sum of squared differences
    return numbers.map {pow($0 - avg, 2)}
        .reduce(0) {(a: Double, b: Double) in
            return a + b
    }
}
