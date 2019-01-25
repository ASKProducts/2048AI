//
//  BalanceScoreFunction
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class BalanceScoreFunction: ScoreFunction {
    
    override func calculateScore(of game: Game) -> Double {
        var score = 0.0
        for r in 0..<game.numRows {
            for c in 0..<game.numCols {
                
                for r2 in r..<game.numRows {
                    for c2 in c..<game.numCols {
                        score += Double( game.piece(r2, c2) - game.piece(r, c) )
                    }
                }
                
            }
        }
        
        return score
    }
    
}


//turns out this is just a weighted score function with the following weights:

/*
 [-15,    -10,    -5,    0],
 [ -10,    -5,    0,    5],
 [ -5,    0,    5,    10],
 [ 0,    5,    10,   15]
 
 
 */

