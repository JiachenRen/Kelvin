//
//  Calculus+nIntegrate.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/21/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import Accelerate

/// Numerical integration based on Accelerate framework
/// Quadrature algorithms ported from Objective C. (Which in turn is ported from C)
/// Learn more about it here:
/// https://developer.apple.com/documentation/accelerate/quadrature
public class Quadrature {
    
    public static var quad_int_options = quadrature_integrate_options(
        integrator: QUADRATURE_INTEGRATE_QAGS,
        abs_tolerance: 1E-10,
        rel_tolerance: 0,
        qag_points_per_interval: 0,
        max_intervals: 35 // Higher max interval leads to more accurate result
    )
    
    /// Status of the integration result.
    /// 0 = success, < 0 = failure, > 0 = inaccurate
    public static var status = quadrature_status(rawValue: 0)
    
    /// The absolute error of the computed integral
    public static var absErr = 0.0
    
    /// Computes each y value by supplying the integrand with the x value.
    private static let quad_int_arr: quadrature_function_array = {(pointer, size, __x, __y) in
        var _x = Array(UnsafeBufferPointer(start: __x, count: size))
        let intFn = pointer!.assumingMemoryBound(to: QArgument.self).pointee
        _x = _x.map {
            intFn.evaluate(at: $0)
        }
        __y.assign(from: UnsafePointer(_x), count: size)
    }
    
    /// Quadracture integrand and variable wrapper
    private class QArgument {
        var integrand: Node
        var variable: Variable
        
        init(_ integrand: Node, _ variable: Variable) {
            self.integrand = integrand
            self.variable = variable
        }
        
        /// Evaluates the integrand at x
        func evaluate(at x: Double) -> Double {
            Variable.define(variable.name, Float80(x))
            let simplified = try! integrand.simplify()
            return Double(simplified≈!)
        }
    }
    
    /// Computes the definite integral of `integrand` from `lb` to `ub` with respect to variable `v`.
    ///
    /// - Todo: Prevent crash if an invalid integrand is passed in as argument
    /// - Parameters:
    ///     - integrand: The function to be integrated
    ///     - lb: Lower bound of the definite integral
    ///     - ub: Upper bound of the definite integral
    ///     - v: The independent variable of `integrand`
    ///
    /// - Precondition: The integrand must be **univariate**.
    public static func integrate(
        _ integrand: Node,
        from lb: Double,
        to ub: Double,
        withRespectTo v: Variable
    ) throws -> Double {
        
        var arg = QArgument(integrand, v)
        var quad_int_fun = quadrature_integrate_function(
            fun: quad_int_arr,
            fun_arg: &arg
        )
        Scope.save()
        
        // Calculate the definite integral using Swift's Accelerate framework
        let integral = quadrature_integrate(
            &quad_int_fun,
            lb,
            ub,
            &quad_int_options,
            &status,
            &absErr,
            0,
            nil
        )
        Scope.restore()
        switch status.rawValue {
        case -101:
            let msg = "the requested accuracy could not be reached when attempting to integrate. \(integrand.stringified)" +
                " with respect to \(v.stringified) - abs_tolerance: \(quad_int_options.abs_tolerance);" +
            " abs_err: \(absErr); integral: \(integral)"
            Program.shared.io?.warning(msg)
            fallthrough
        case 0:
            return integral
        default:
            let msg = "an unknown error has occurred when integrating \(integrand.stringified)" +
            " with respect to \(v.stringified) - error code: \(status);"
            throw ExecutionError.general(errMsg: msg)
        }
    }
}
