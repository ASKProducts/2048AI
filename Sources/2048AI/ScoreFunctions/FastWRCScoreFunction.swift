//
//  FastWRCScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/24/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//FastWRCScoreFunction stands for Fast Weighted Row-Column Score Function. It's a weighted score function where there are only four weights and the row and column score functions are the same

class FastWRCScoreFunction: FastScoreFunction {
    
    let weights: [Double]
    
    init(weights: [Double]) {
        self.weights = weights
    }
    
    override func rowScore(row: Int, entries: [Double]) -> Double {
        return zip(entries, weights).map{$0.0 * $0.1}.reduce(0.0, +)
    }
    
    override func colScore(col: Int, entries: [Double]) -> Double {
        return zip(entries, weights).map{$0.0 * $0.1}.reduce(0.0, +)
    }
    
}
