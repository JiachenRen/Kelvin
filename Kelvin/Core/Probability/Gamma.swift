//
//  Gamma.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Computes an approximate value for the gamma function
public class Gamma {
    
    /// Lanczos
    private static let pArr: [Float80] = [
        0.99999999999980993,
        676.5203681218851,
        -1259.1392167224028,
        771.32342877765313,
        -176.61502916214059,
        12.507343278686905,
        -0.13857109526572012,
        9.9843695780195716e-6,
        1.5056327351493116e-7
    ]
    
    private static let pLnArr: [Float80] = [
        0.99999999999999709182,
        57.156235665862923517,
        -59.597960355475491248,
        14.136097974741747174,
        -0.49191381609762019978,
        0.33994649984811888699e-4,
        0.46523628927048575665e-4,
        -0.98374475304879564677e-4,
        0.15808870322491248884e-3,
        -0.21026444172410488319e-3,
        0.21743961811521264320e-3,
        -0.16431810653676389022e-3,
        0.84418223983852743293e-4,
        -0.26190838401581408670e-4,
        0.36899182659531622704e-5
    ]
    
    private static let g: Float80 = 7
    private static let gLn: Float80 = 607 / 128
    
    /// Γ(n) = (n-1)!
    /// One of extensions of the factorial function with its argument shifted down by 1
    ///
    /// - Defines factorial for non-integer values.
    /// - Source: https://github.com/ythecombinator/GammaFn/
    public static func gamma(_ value: Float80) throws -> Float80 {
        
        switch value {
        case let x where x < 0.5:
            return try Float80.pi / (sin(Float80.pi * value) * logForGamma(1 - value))
        case let x where x > 100:
            return try exp(logForGamma(value))
        default:
            let decreasedValue: Float80 = value - 1
            var x = pArr[0]
            
            for i in stride(from: 1, to: g + 2, by: 1){
                let index = Int(i)
                x += pArr[index] / (decreasedValue + i)
            }
            
            let t = decreasedValue + g + 0.5
            
            return
                sqrt(2 * Float80.pi)
                    * pow(t, decreasedValue + 0.5)
                    * exp(-t)
                    * x
        }
    }
    
    public static func logForGamma(_ value: Float80) throws -> Float80 {
        
        if value < 0 {
            throw ExecutionError.domain(
                value,
                lowerBound: 0,
                upperBound: Float80.infinity
            )
        }
        
        var x = pLnArr[0]
        
        for i in (0..<pLnArr.count - 1).reversed() {
            let index = Float80(i)
            x += pLnArr[i] / (value + index)
        }
        
        let t = value + gLn + 0.5
        
        return
            0.5
                * log(2 * Float80.pi)
                + (value + 0.5)
                * log(t)
                - t
                + log(x)
                - log(value)
    }
}
