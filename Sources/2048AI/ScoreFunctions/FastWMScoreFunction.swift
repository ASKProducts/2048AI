//
//  FastWMScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//Fast Weighted-Merger Score Function

//acts the same as a weighted score function but with an additional parameter mergeFactor, which acts by adding mergeFactor*N to the score whenever there are two tiles of rank N adjacent

class FastWMScoreFunction : FastWeightedScoreFunction {
    
    let mergeFactor: Double
    
    init(weights: [[Double]], mergeFactor: Double = 0.0, square: Bool = false) {
        self.mergeFactor = mergeFactor
        super.init(weights: weights, square: square)
    }
    
    override func rowScore(row: Int, entries: [Double]) -> Double {
        var score = 0.0
        for i in 0..<3 {
            if entries[i] == entries[i+1]{
                score += mergeFactor*entries[i]
            }
        }
        return score + super.rowScore(row: row, entries: entries)
    }
    
    override func colScore(col: Int, entries: [Double]) -> Double {
        var score = 0.0
        for i in 0..<3 {
            if entries[i] == entries[i+1]{
                score += mergeFactor*entries[i]
            }
        }
        return score + super.colScore(col: col, entries: entries)
    }
    
    
    
}
