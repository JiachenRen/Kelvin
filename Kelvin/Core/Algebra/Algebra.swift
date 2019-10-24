//
//  Algebra.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Collection of algebraic operations.
public class Algebra {
    public typealias PolyTerm = (degree: Int, coef: Node)
    
    /// Finds all rational roots of polynomial using the **Rational Root Theorem**.
    /// According to the theorem, all of the rational roots of polynomial
    /// `a_n*x^n + a_{n-1}^x^{n-1}+...a_1*x+a_0` has the form
    /// `p/q`, where `{p|±(factors of a_0)}` and `{q|±(factors of a_n)}`
    /// - Parameters:
    ///     - poly: A polynomial with `v` as its variable.
    ///     - v: The variable that the polynomial is expressed in.
    /// - Returns: A list of rational roots of `poly`.
    public static func findRRoots(of poly: Node, _ v: Variable) throws -> [Node] {
        var terms = try coefficients(of: poly, v)
        var roots: [Node] = []
        // If the polynomial has only the constant term, then it has no roots.
        if terms.count == 1 {
            return []
        }
        while let c = terms.first?.coef, c === 0 {
            terms.removeFirst()
            roots.append(0)
        }
        guard let f = terms.first?.coef as? Integer,
            let l = terms.last?.coef as? Integer else {
                let msg = "cannot guess rational root of a polynomial with non-integer lowest/highest degree term coefficients"
                throw ExecutionError.general(errMsg: msg)
        }
        for p in f.bigInt.factors() {
            for q in l.bigInt.factors() {
                for sign in [1, -1] {
                    let e = sign * p as Node / q as Node
                    let test = poly.replacing(
                        by: { _ in e },
                        where: { $0 === v }
                    )
                    if try test.simplify() === 0 {
                        roots.append(e)
                    }
                }
            }
        }
        return roots
    }
    
    /// Deconstructs the given polynomial into a list of tuples of form `(degree, coef)`.
    /// Sorted in order of rising degree.
    /// - Parameters:
    ///     - poly: A polynomial with `v` as its variable.
    ///     - v: The variable that the polynomial is expressed in.
    /// - Returns: A list of `(degree, coef)` tuples that represent the polynomial.
    /// - Throws: `ExecutionError.invalidPolynomial` if the `poly` is not a polynomial.
    public static func coefficients(of poly: Node, _ v: Variable) throws -> [PolyTerm] {
        let expanded = try expand(poly).simplify()
        var list = [PolyTerm]()
        if let fun = expanded as? Function {
            switch fun.name {
            case .add:
                try termsFromAdd(fun, v, &list)
            case .mult, .power:
                try extractPolyTerm(fun, v, &list)
            default:
                break
            }
        }
        // If the polynomial has only the constant term
        if !expanded.contains(where: {$0 === v}, depth: .max) {
            return [(0, expanded)]
        }
        // Not a valid polynomial.
        if list.count == 0 {
            throw ExecutionError.invalidPolynomial(poly)
        }
        // Fill in missing degrees and sorts terms in order of rising degree.
        list.sort(by: { $0.degree < $1.degree })
        var i = 0
        while i < list.count {
            if list[i].degree != i {
                list.insert((i, 0), at: i)
            }
            i += 1
        }
        return list
    }
    
    /// Helper for `coefficients(of:)` - extracts polynomial terms from an addition.
    private static func termsFromAdd(_ addition: Function, _ v: Variable, _ list: inout [PolyTerm]) throws {
        let addants = addition.elements
        var consts = [Node]()
        var terms = [Node]()
        for a in addants {
            if a.contains(where: {$0 === v}, depth: .max) {
                terms.append(a)
            } else {
                consts.append(a)
            }
        }
        let constTerm = (degree: 0, coef: ++consts)
        list.append(constTerm)
        try terms.forEach {
            try extractPolyTerm($0, v, &list)
        }
    }
    
    /// Helper for `coefficients(of:)` - extracts polynomial term from a term, where term could be a product or a variable.
    private static func extractPolyTerm(_ node: Node, _ v: Variable, _ list: inout [PolyTerm]) throws {
        let term = ((node as? Function)?.name == .mult ? node : node * 1) as! Function
        for (i, e) in term.elements.enumerated() {
            let validate: () throws -> [Node] = {
                var copy = term.elements
                copy.remove(at: i)
                for j in copy {
                    if j.contains(where: {$0 === v}, depth: .max) {
                        throw ExecutionError.invalidPolynomial(term)
                    }
                }
                return copy
            }
            if e === v {
                let rest = try validate()
                let term = (degree: 1, coef: **rest)
                list.append(term)
            } else if let fun = e as? Function,
                fun.name == .power,
                let base = fun.elements.first,
                base === v {
                let rest = try validate()
                guard let degree = fun.elements.last as? Int else {
                    throw ExecutionError.invalidPolynomial(term)
                }
                let term = (degree, **rest)
                list.append(term)
            } else if e.contains(where: {$0 === v}, depth: .max) {
                throw ExecutionError.invalidPolynomial(term)
            }
        }
    }
}
