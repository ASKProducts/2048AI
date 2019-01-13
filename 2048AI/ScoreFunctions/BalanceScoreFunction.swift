//
//  BalanceScoreFunction
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

func balanceScoreFunc(game: Game) -> Double {
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
