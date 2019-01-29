//
//  FastWRCScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/24/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//FastWRCScoreFunction stands for Fast Weighted Row-Column Score Function. It's a weighted score function where there are only four weights and the row and column score functions are the same

class FastWRCScoreFunction: FastWMScoreFunction {
    
    init(weights: [Double], mergeFactor: Double = 0.0) {
        var realWeights: [[Double]] = []
        for r in 0..<4 {
            realWeights.append([])
            for c in 0..<4 {
                realWeights[r].append(weights[r] + weights[c])
            }
        }
        
        super.init(weights: realWeights, mergeFactor: mergeFactor)
    }
    
}
