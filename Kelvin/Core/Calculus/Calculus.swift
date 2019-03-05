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
    static let operations: [Operation] = [
        .binary(.derivative, [.any, .var]) {
            let v = $1 as! Variable
            Scope.withholdAccess(to: v)
            let dv = derivative(
                of: try $0.simplify(),
                withRespectTo: v
            )
            Scope.releaseRestrictions()
            return dv
        },
        .ternary(.derivative, [.any, .var, .number]) {
            let v = $1 as! Variable
            Scope.withholdAccess(to: v)
            let dnv = try derivative(
                of: $0.simplify(),
                withRespectTo: v,
                $2.simplify() as! Int
            )
            Scope.releaseRestrictions()
            return dnv
        },
        .ternary(.implicitDifferentiation, [.any, .var, .var]) {
            let dv = $1 as! Variable
            let iv = $2 as! Variable
            Scope.withholdAccess(to: dv, iv)
            let eq = try Assert.cast($0.simplify(), to: Equation.self)
            let r = try implicitDifferentiation(
                eq,
                dependentVar: dv,
                independentVar: iv
            )
            Scope.releaseRestrictions()
            return r
        },
        .binary(.gradient, [.any, .list]) {
            let vars = try Assert.specialize(list: $1 as! List, as: Variable.self)
            Scope.withholdAccess(to: vars)
            let fun = try Assert.cast($0.simplify(), to: Function.self)
            let grad = gradient(of: fun, independentVars: vars)
            Scope.releaseRestrictions()
            return grad
        },
        .ternary(.directionalDifferentiation, [.func, .list, .any]) {
            let vars = try Assert.specialize(list: $1 as! List, as: Variable.self)
            let dir = try Assert.cast($2.simplify(), to: Vector.self)
            Scope.withholdAccess(to: vars)
            let fun = try Assert.cast($0.simplify(), to: Function.self)
            let grad = try directionalDifferentiation(
                of: fun,
                direction: dir,
                independentVars: vars
            )
            Scope.releaseRestrictions()
            return grad
        },
        .ternary(.tangent, [.func, .list, .any]) {
            let vars = try Assert.specialize(list: $1 as! List, as: Variable.self)
            let vec = try Assert.cast($2.simplify(), to: Vector.self)
            Scope.withholdAccess(to: vars)
            let fun = try Assert.cast($0.simplify(), to: Function.self)
            let tan = try tangent(
                of: fun,
                variables: vars,
                at: vec
            )
            Scope.releaseRestrictions()
            return tan
        },
        
        // Mark: Integration
        .quaternary(.numericalIntegration, [.any, .var, .number, .number]) {
            let integral = try Quadrature.integrate(
                $0,
                from: Double($2≈!),
                to: Double($3≈!),
                withRespectTo: $1 as! Variable
            )
            return Float80(integral)
        }
    ]
}
