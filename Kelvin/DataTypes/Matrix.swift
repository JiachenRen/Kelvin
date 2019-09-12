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
            return $0 == nil ? $1.stringified : $0! + ", " + $1.stringified
        }
        return "[\(r!)]"
    }
    
    public var ansiColored: String {
        let r = rows.reduce(nil) {
            return $0 == nil ? $1.ansiColored : $0! + ", " + $1.ansiColored
        }
        return "[".red.bold + "\(r!)" + "]".red.bold
    }
    
    public var precedence: Keyword.Precedence {
        return .node
    }
    
    public typealias Row = Vector
    public typealias Dimension = (rows: Int, cols: Int)
    public typealias Cell = (row: Int, col: Int, node: Node)
    
    public var rows: [Row]
    public var cols: [Vector] {
        return transposed.rows
    }
    
    public var transposed: Matrix {
        var trans = Matrix(rows: dim.cols, cols: dim.rows)
        for (i, r) in rows.enumerated() {
            for (j, e) in r.elements.enumerated() {
                trans[j][i] = e
            }
        }
        return trans
    }
    
    public var dim: Dimension
    
    public var isSquareMatrix: Bool {
        return rows.count == rows.first!.count
    }
    
    public var cells: [Cell] {
        return rows.enumerated().map {(i, r) in
            r.elements.enumerated().map {(j, e) in
                (i, j, e)
            }
        }.flatMap {$0}
    }
    
    public subscript(_ idx: Int) -> Row {
        get {
            return rows[idx]
        }
        set {
           rows[idx] = newValue
        }
    }
    
    public var elements: [Node] {
        set {
            if let rows = newValue as? [Row] {
                self.rows = rows
                return
            }
        }
        get {
            return self.rows
        }
    }
    
    public init(_ dim: Int) {
        self.init(rows: dim, cols: dim)
    }
    
    public init(rows: Int, cols: Int) {
        self.rows = [Row](repeating: Vector([Int](repeating: 0, count: cols)), count: rows)
        self.dim = (rows, cols)
    }
    
    public init(_ list: ListProtocol, rows: Int, cols: Int) throws {
        if list.count != rows * cols {
            let msg = "cannot create a \(rows) x \(cols) matrix from a list of \(list.count) elements"
            throw ExecutionError.general(errMsg: msg)
        }
        let elements = list.elements
        self.dim = (rows, cols)
        self.rows = stride(from: 0, to: elements.count, by: cols).map {
            Row(Array(elements[$0..<min($0 + cols, elements.count)]))
        }
    }
    
    public init(_ list: ListProtocol) throws {
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
    
    public init(_ rows: [Row]) throws {
        self.rows = rows
        if rows.count < 1 || rows.first!.count < 1 {
            throw ExecutionError.general(errMsg: "cannot create empty matrix")
        }
        for i in 0..<rows.count - 1 {
            if rows[i].count != rows[i + 1].count {
                throw ExecutionError.general(errMsg: "failed to initialize matrix due to non-uniform row dimension")
            }
        }
        self.dim = (rows: rows.count, cols: rows[0].count)
    }
    
    public init(_ mat: [[Node]]) throws {
        try self.init(mat.map {Row($0)})
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
    
    /**
     For performing addition and subtraction of matrices of same dimension.
     
     - Warning: Do not pass in mult or div as binary operations, as matrices have no such definitions!
     */
    public func perform(_ bin: Binary, with mat: Matrix) throws -> Matrix {
        try Assert.dimension(self, mat)
        var copy = self
        cells.forEach {(i, j, e) in
            copy[i][j] = bin(e, mat[i][j])
        }
        return copy
    }
    
    public func transform(by unary: Unary) -> Matrix {
        var mat = self
        cells.forEach {(i, j, e) in
            mat[i][j] = unary(e)
        }
        return mat
    }
    
    public func transform(by unary: (Cell) -> Node) -> Matrix {
        var mat = self
        cells.forEach {cell in
            mat[cell.row][cell.col] = unary(cell)
        }
        return mat
    }
    
    /**
     Matrix multiplication. The resultant matrix is generated by
     dotting each row with each column of the input matrix.
     */
    public func mult(_ mat: Matrix) throws -> Matrix {
        let trans = mat.transposed
        var newRows = [Row]()
        for r in rows {
            var row = [Node]()
            for c in trans.rows {
                row.append(try r.dot(with: c))
            }
            let vec = Vector(row)
            newRows.append(vec)
        }
        
        return try Matrix(newRows)
    }
    
    /// Converts the matrix to a 2D array of specified type
    public func specialize<T>(as type: T.Type) throws -> [[T]] {
        return try rows.map {row in
            try row.map {
                guard let specialized = $0 as? T else {
                    let msg = "cannot cast \($0.stringified) to \(T.self)"
                    throw ExecutionError.general(errMsg: msg)
                }
                return specialized
            }
        }
    }
    
    public func setColumn(_ i: Int, _ column: Vector) throws -> Matrix {
        try Assert.index(dim.cols, i)
        guard column.count == dim.rows else {
            throw ExecutionError.dimensionMismatch(self, column)
        }
        var t = transposed
        t[i] = column
        return t
    }
    
    /**
     Calculates the determinant of the matrix using cofactor expansion.
     Pick any i∈{1,…,n}, then
     det(A)=(−1)^(i+1)*A(i,1)*det(A(i,1))+(−1)^(i+2)*A(i,2)*det(A(i∣2))+⋯+(−1)^(i+n)*A(i,n)*det(A(i∣n)).
     Refer to http://people.math.carleton.ca/~kcheung/math/notes/MATH1107/wk07/07_cofactor_expansion.html.
     
     - Note: The determinant only exists for square matrices.
     */
    public func determinant() throws -> Node {
        try Assert.squareMatrix(self)
        if count == 1 { // Base case
            return self[0][0]
        }
        
        // Expand along the first row
        return try rows[0].elements.enumerated().reduce(0) {
            (det, e) -> Node in
            let sign = e.offset % 2 == 0 ? 1 : -1
            let cofDet = try cofactor(row: 0, col: e.offset).determinant()
            
            // Accelerate by simplifying the expression on the fly
            return try (det + e.element * cofDet * sign)
                .simplify()
        }
    }
    
    /// Computes the minor cofactor of the matrix
    /// - Parameters:
    ///     - row: The row to be excluded
    ///     - col: The column to be excluded
    public func cofactor(row r: Int, col c: Int) throws -> Matrix {
        try Assert.squareMatrix(self)
        try Assert.index(dim.rows, r)
        try Assert.index(dim.cols, c)
        
        var i = 0, j = 0, n = count
        var cofactor = Matrix(n - 1)
        
        // Looping for each element of the matrix
        for row in 0..<n {
            for col in 0..<n {
                
                // Copying into temporary matrix
                // only those element which are
                // not in given row and column
                if (row != r && col != c) {
                    cofactor[i][j] = self[row][col]
                    j += 1
                    
                    // Row is filled, so increase
                    // row index and reset col index
                    if (j == n - 1) {
                        j = 0;
                        i += 1
                    }
                }
            }
        }
        
        return cofactor
    }
    
    /// Computes the cofactor matrix.
    /// - Note: Cofactor matrix only exists for square matrices
    public func cofactorMatrix() throws -> Matrix {
        var coMat = Matrix(count)
        try cells.forEach {(i, j, _) in
            coMat[i][j] = try cofactor(row: i, col: j).determinant()
        }
        return coMat
    }
    
    /**
     Creates an identity matrix of the specified dimension
     The identity matrix, I2 for example, is
     [[1, 0], [0, 1]]; The identity matrix I3 is
     [[1, 0, 0], [0, 1, 0], [0, 0, 1]].
     
     - Parameter dim: The dimension of the identity matrix.
     - Returns: An identity matrix of the specified dimension.
     */
    public static func identityMatrix(_ dim: Int) -> Matrix {
        var mat = Matrix(dim)
        for i in 0..<dim {
            mat[i][i] = 1
        }
        return mat
    }
    
}
