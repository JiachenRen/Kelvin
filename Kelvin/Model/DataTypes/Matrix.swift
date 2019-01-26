//
//  Matrix.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/25/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Matrix: MutableListProtocol, NaN {
    
    public var stringified: String {
        let r = rows.reduce(nil) {
            return $0 == nil ? $1.stringified : $0!.stringified + ", " + $1.stringified
        }
        return "[\(r!)]"
    }
    
    public typealias Row = Vector
    public typealias Dimension = (rows: Int, cols: Int)
    
    var rows: [Row]
    
    var dim: Dimension
    
    subscript(_ idx: Int) -> Row {
        return rows[idx]
    }
    
    public var elements: [Node] {
        set {
            if let rows = newValue as? [Row] {
                self.rows = rows
                return
            }
            fatalError()
        }
        get {
            return self.rows
        }
    }
    
    init(_ list: ListProtocol) throws {
        if list.count == 0 {
            throw ExecutionError.general(errMsg: "cannot create matrix from empty list")
        }
        var rows = [Row]()
        var isProperMatrix = true
        for e in list.elements {
            if let row = Vector(e) {
                rows.append(row)
            } else {
                isProperMatrix = false
                break
            }
        }
        
        if !isProperMatrix {
            rows = [Row]()
            rows.append(Vector(list)!)
        }
        
        try self.init(rows)
    }
    
    init(_ rows: [Row]) throws {
        self.rows = rows
        if rows.count < 1 || rows.first!.count < 1 {
            throw ExecutionError.general(errMsg: "cannot create empty matrix")
        }
        
        for i in 0..<rows.count - 1 {
            if rows[i].count != rows[i + 1].count {
                throw ExecutionError.dimensionMismatch
            }
        }
        
        self.dim = (rows: rows.count, cols: rows[0].count)
    }
    
    public func equals(_ node: Node) -> Bool {
        guard let matrix = node as? Matrix else {
            return false
        }
        
        if matrix.dim != dim {
            return false
        }
        
        for (i, r) in matrix.rows.enumerated() {
            if r !== self[i] {
                return false
            }
        }
        
        return true
    }
    
}
