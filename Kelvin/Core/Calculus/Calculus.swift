//
//  Calculus.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Calculus {
    
    /// Calculus operations
    public static let operations: [Operation] = [
        .binary(.derivative, [.any, .var]) {
            let v = $1 as! Variable
            Scope.withholdAccess(to: v)
            let dv = Calculus.derivative(
                of: try $0.simplify(),
                withRespectTo: v)
            Scope.releaseRestrictions()
            return dv
        },
        .init(.derivative, [.any, .var, .number]) {
            let v = $0[1] as! Variable
            Scope.withholdAccess(to: v)
            let dnv = try Calculus.derivative(
                of: $0[0].simplify(),
                withRespectTo: v,
                $0[2].simplify() as! Int)
            Scope.releaseRestrictions()
            return dnv
        },
        .init(.implicitDifferentiation, [.any, .var, .var]) {
            let dv = $0[1] as! Variable
            let iv = $0[2] as! Variable
            Scope.withholdAccess(to: dv, iv)
            guard let eq = try $0[0].simplify() as? Equation else {
                let msg = "left hand side of implicit differentiation must be an equation"
                throw ExecutionError.general(errMsg: msg)
            }
            let r = try Calculus.implicitDifferentiation(
                eq,
                dependentVar: dv,
                independentVar: iv)
            Scope.releaseRestrictions()
            return r
        },
        .binary(.gradient, [.any, .list]) {
            let vars = try extractVariables(from: $1 as! List)
            
            Scope.withholdAccess(to: vars)
            guard let fun = try $0.simplify() as? Function else {
                let msg = "cannot find gradient of non-functional type \($0.stringified)"
                throw ExecutionError.general(errMsg: msg)
            }
            let grad = Calculus.gradient(
                of: fun,
                independentVars: vars)
            Scope.releaseRestrictions()
            return grad
        },
        .init(.directionalDifferentiation, [.func, .list, .any]) {
            let vars = try extractVariables(from: $0[1] as! List)
            
            guard let dir = try $0[2].simplify() as? Vector else {
                throw ExecutionError.general(errMsg: "direction must be a vector")
            }
            
            Scope.withholdAccess(to: vars)
            guard let fun = try $0[0].simplify() as? Function else {
                let msg = "cannot directional differentiate non-functional type \($0[0].stringified)"
                throw ExecutionError.general(errMsg: msg)
            }
            let grad = try Calculus.directionalDifferentiation(
                of: fun,
                direction: dir,
                independentVars: vars)
            Scope.releaseRestrictions()
            return grad
        },
        .init(.tangent, [.func, .list, .any]) {
            let vars = try extractVariables(from: $0[1] as! List)
            guard let vec = try $0[2].simplify() as? Vector else {
                let msg = "value supplied for finding tangential line/plane/surface must be a vector"
                throw ExecutionError.general(errMsg: msg)
            }
            
            Scope.withholdAccess(to: vars)
            guard let fun = try $0[0].simplify() as? Function else {
                let msg = "cannot find tangent of non-functional type \($0[0].stringified)"
                throw ExecutionError.general(errMsg: msg)
            }
            let tangent = try Calculus.tangent(
                of: $0[0] as! Function,
                variables: vars,
                at: vec)
            Scope.releaseRestrictions()
            return tangent
        }
    ]
    
    private static func extractVariables(from list: List) throws -> [Variable] {
        return try list.elements.map {
            (n: Node) -> Variable in
            if let v = n as? Variable {
                return v
            }
            throw ExecutionError.unexpectedType(
                list,
                expected: .variable,
                found: try .resolve(n))
        }
    }
}
