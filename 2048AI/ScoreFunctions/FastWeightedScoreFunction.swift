//
//  FastWeightedScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation


class FastWeightedScoreFunction: FastScoreFunction{
    
    let weights: [[Double]]
    
    init(weights: [[Double]]) {
        self.weights = weights
        super.init()
    }
    
    override func rowScore(row: Int, entries: [Double]) -> Double {
        
        return zip(self.weights[row], entries).map{$0.0 * $0.1}.reduce(0.0, +)
        
        //traditional way:
        /*
        var score = 0.0
        for i in 0..<4 {
            score += self.weights[row][i]*entries[i]
        }
        return score*/
        
        //just for fun, here is how to do it without map:
        //return zip(self.weights[row], entries).reduce(0.0){$0 + ($1.0 * $1.1)}
    }
    
}
