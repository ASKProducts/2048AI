//
//  ClusterScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/2/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//the idea of this score function is that it rewards boards where the largest pieces are clustered together. It was my dad's idea; it doesn't work very well...
class ClusterScoreFunction: ScoreFunction {
    
    override func calculateScore(of game: Game) -> Double {
        var score = 0.0
        var biggestSpot = Spot(0, 0)
        var biggestPiece = -1
        
        for r in 0..<game.numRows {
            for c in 0..<game.numCols {
                if game.piece(r, c) > biggestPiece {
                    biggestPiece = game.piece(r, c)
                    biggestSpot = Spot(r, c)
                }
            }
        }
        
        for r in 0..<game.numRows {
            for c in 0..<game.numCols {
                let distToMax = Double(max(abs(r-biggestSpot.r), abs(c-biggestSpot.c)))
                score += Double(game.piece(r, c))/pow(2.0, distToMax)
            }
        }
        return score
    }
    
    override var description: String {
        return "{Cluster}"
    }
    
}
