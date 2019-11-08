//
//  Exports+calculus.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let calculus = Calculus.exports
}

extension Calculus {
    static let exports: [Operation] = [
        .binary(.derivative, [.node, .variable]) {
            let v = $1 as! Variable
            Scope.withholdAccess(to: v)
            let dv = derivative(
                of: try $0.simplify(),
                withRespectTo: v
            )
            Scope.releaseRestrictions()
            return dv
        },
        .ternary(.derivative, [.node, .variable, .number]) {
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
        .ternary(.implicitDifferentiation, [.node, .variable, .variable]) {
            let dv = $1 as! Variable
            let iv = $2 as! Variable
            Scope.withholdAccess(to: dv, iv)
            let eq = try $0.simplify() ~> Equation.self
            let r = try implicitDifferentiation(
                eq,
                dependentVar: dv,
                independentVar: iv
            )
            Scope.releaseRestrictions()
            return r
        },
        .binary(.gradient, [.node, .list]) {
            let vars = try Assert.specialize(list: $1 as! List, as: Variable.self)
            Scope.withholdAccess(to: vars)
            let fun = try $0.simplify() ~> Function.self
            let grad = gradient(of: fun, independentVars: vars)
            Scope.releaseRestrictions()
            return grad
        },
        .ternary(.directionalDifferentiation, [.function, .list, .node]) {
            let vars = try Assert.specialize(list: $1 as! List, as: Variable.self)
            let dir = try $2.simplify() ~> Vector.self
            Scope.withholdAccess(to: vars)
            let fun = try $0.simplify() ~> Function.self
            let grad = try directionalDifferentiation(
                of: fun,
                direction: dir,
                independentVars: vars
            )
            Scope.releaseRestrictions()
            return grad
        },
        .ternary(.tangent, [.function, .list, .node]) {
            let vars = try Assert.specialize(list: $1 as! List, as: Variable.self)
            let vec = try $2.simplify() ~> Vector.self
            Scope.withholdAccess(to: vars)
            let fun = try $0.simplify() ~> Function.self
            let tan = try tangent(
                of: fun,
                variables: vars,
                at: vec
            )
            Scope.releaseRestrictions()
            return tan
        },
        
        .binary(.criticalPoints, Node.self, Variable.self) {
            Function(.solve, [Equation(lhs: Function(.derivative, [$0, $1]), rhs: 0)])
        },
        
        // Mark: Integration
        .quaternary(.numericalIntegration, [.node, .variable, .number, .number]) {
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
