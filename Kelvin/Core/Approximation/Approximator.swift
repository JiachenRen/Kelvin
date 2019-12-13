//
//  Approximator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/21/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

/// Original IP of Jiachen Ren, guess fractions, rational numbers, etc.
public class Approximator {
    /// Maximum possible value of denominator for the approximated fraction.
    private static let maxDenominator = 1000
    /// Root node of the floating point -- fraction CharTree.
    private static var fractRoot: CharTree<Fraction> = {
        Program.shared.io?.log("initializing fractional approximator, please wait...")
        let root = CharTree<Fraction>()
        for i in 2...maxDenominator {
            for j in 1..<i {
                let r = Float80(j) / Float80(i)
                root.store(String(r), Fraction(j, i), overwrite: false)
            }
        }
        return root
    }()
    
    /// Guess a fraction (not really a guess, the result is deterministic) that has exactly the value of the provided float.
    /// Provided float80 must be a value between 0 and 1
    /// - Returns: A nicely looking fraction with `denominator < matDenominator` that is exactly equal to the float80 provided.
    public static func guessFraction(exactly float80: Float80) throws -> Fraction? {
        try Assert.domain(float80, 0, 1)
        let sign: BigInt = float80 < 0 ? -1 : 1
        let query = String(abs(float80))
        return fractRoot.retrieve(exactly: query)?.multiplying(sign)
    }
    
    /// Retrieves all possible fractional representations of the given float accurate to specified decimal places.
    public static func guessFraction(_ float80: Float80, accurateTo decimalPlace: Int) throws -> [Fraction] {
        try Assert.domain(decimalPlace, 1, 100)
        let sign: BigInt = float80 < 0 ? -1 : 1
        let str = String(abs(float80))
        if str.contains("e") { throw ExecutionError.general(errMsg: "provided float too big to approximate") }
        let segments = str.split(separator: ".")
        guard segments.count == 2 else { return [] }
        if decimalPlace >= segments[1].count,
            let exact = try guessFraction(exactly: Float80("0.\(segments[1])")!) {
            Program.shared.io?.log("exact representation is possible; only exact result returned")
            return [exact.adding(Int(segments[0])!).multiplying(sign)]
        }
        let query = "0.\(segments[1].prefix(decimalPlace))"
        return fractRoot.retrieve(approximately: query)
            .map { $0.multiplying(sign) }
    }
    
    public static func genAssets() throws {
        let encoder = JSONEncoder()
        let asset = try encoder.encode(fractRoot)
        let url = URL(fileURLWithPath: "/tmp/assets.json")
        try FileSystem.shared.createFile(at: url.path)
        try asset.write(to: url)
    }
    
    public static func loadAssets() throws {
        let decoder = JSONDecoder()
        print("loading data from file")
        let data = try Data(contentsOf: URL(fileURLWithPath: "/tmp/assets.json"))
        print("decoding...")
        fractRoot = try decoder.decode(CharTree<Fraction>.self, from: data)
    }
    
    /// A tree ADT for quick retrieval of likely fraction equivalent of a decimal value.
    private class CharTree<T: Codable>: Codable {
        var children: [String: CharTree<T>]
        var val: T?
        
        init() {
            children = [:]
        }
        
        /// Stores `val` by recursively deconstruct the `key` into levels of the tree.
        /// - Parameter key: The exact key for the value.
        /// - Parameter overwrite: Whether to overwrite the value of a key if it already exists.
        /// - Parameter val: The value to be stored.
        func store(_ key: String, _ val: T, overwrite: Bool = true) {
            guard let c = key.first else {
                self.val = (self.val == nil || overwrite) ? val : self.val
                return
            }
            let s = String(c)
            if children[s] == nil {
                let tree = CharTree()
                children[s] = tree
            }
            let frac = children[s]!
            let key = String(key.dropFirst())
            frac.store(key, val, overwrite: overwrite)
        }
        
        /// Retrieves the value with exactly the provided key.
        func retrieve(exactly key: String) -> T? {
            guard let c = key.first else {
                return val
            }
            let s = String(c)
            return children[s]?.retrieve(exactly: String(key.dropFirst()))
        }
        
        /// Retrieve values of all children and grandchildren, excluding value of self.
        func retrieveAll() -> [T] {
            var vals = children.values.compactMap { $0.val }
            children.values.forEach {
                vals.append(contentsOf: $0.retrieveAll())
            }
            return vals
        }
        
        /// Retrieves values with partially matching key.
        func retrieve(approximately key: String) -> [T] {
            guard let c = key.first else {
                var valOfChildren = retrieveAll()
                if let val = self.val {
                    valOfChildren.insert(val, at: 0)
                }
                return valOfChildren
            }
            let s = String(c)
            return children[s]?.retrieve(approximately: String(key.dropFirst())) ?? []
        }
    }
}
