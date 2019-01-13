//
//  PowerScoreFunctions.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/2/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

func squareScoreFunc(game: Game) -> Double {
    var score = 0.0
    for r in 0..<game.numRows {
        for c in 0..<game.numCols {
            score += Double(game.piece(r, c)*game.piece(r, c))
        }
    }
    
    return score
}



func cubeScoreFunc(game: Game) -> Double {
    var score = 0.0
    for r in 0..<game.numRows {
        for c in 0..<game.numCols {
            score += Double(game.piece(r, c)*game.piece(r, c)*game.piece(r, c))
        }
    }
    
    return score
}

func powerScoreFunc(exponent: Double) -> ScoreFunc {
    
    func scoreFunc(game: Game) -> Double {
        var score = 0.0
        for r in 0..<game.numRows {
            for c in 0..<game.numCols {
                score += pow(Double(game.piece(r, c)), exponent)
            }
        }
        
        return score
    }
    
    return scoreFunc
}
