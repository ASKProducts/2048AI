//
//  RandomPlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class RandomPlayer: Player{
    
    override func decide(game: Game) -> Move {
        let moves = Move.mainMoves
        var move = moves[Int.random(in: 0..<4)]
        while !game.canMove(move) {
            move = moves[Int.random(in: 0..<4)]
        }
        return move
    }
    
}
