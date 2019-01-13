//
//  GreedyPlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class GreedyPlayer: Player {
    
    override func decide(game: Game) -> Move {
        let moves = Move.mainMoves
        var bestMove = Move.nothing
        var bestScore = -1.0
        
        for move in moves {
            if !game.canMove(move) { continue }
            let testGame = game.duplicate()
            _ = testGame.makeMove(move)
            let score = testGame.score
            if score > bestScore {
                bestMove = move
                bestScore = score
            }
        }
        
        return bestMove
    }
    
}
