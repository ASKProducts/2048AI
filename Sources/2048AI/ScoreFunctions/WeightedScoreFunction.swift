//
//  WeightedScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

typealias ScoreWeights = [[Double]]

class WeightedScoreFunction: ScoreFunction{
    
    let weights: ScoreWeights
    
    init(weights: ScoreWeights) {
        self.weights = weights
    }
    
    override func calculateScore(of game: Game) -> Double {
        var score = 0.0
        for r in 0..<game.numRows{
            for c in 0..<game.numCols{
                score += weights[r][c]*Double(game.piece(r, c))
            }
        }
        return score
    }
    
    override var description: String {
        return "{Classical Weighted Score Function; Weights: \(self.weights)}"
    }
    
}
