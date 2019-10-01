//
//  Tokenizer.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public typealias Token = Character

public class Tokenizer {

    /// A unicode scalar value that would never interfere with input
    /// In this case, the scalar value (and the ones after)
    /// does not have any unicode counterparts
    private static var scalar = 60000

    /// Reset the scalar
    fileprivate static func reset() {
        scalar = 60000
    }

    /// Generate next available encoding from a unique scalar.
    public static func next() -> Token {

        // Assign a unique code to the operation consisting of
        // an unused unicode
        let encoding = Character(UnicodeScalar(scalar)!)

        // Increment the scalar so that each operator is unique.
        scalar += 1

        return encoding
    }
}
