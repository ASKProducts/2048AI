//
//  SimplePlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class SimplePlayer: Player {
    
    override func decide(game: Game) -> Move {
        if game.canMove(Move.left) { return Move.left }
        if game.canMove(Move.down) { return Move.down }
        if game.canMove(Move.right) { return Move.right }
        if game.canMove(Move.up) { return Move.up }
        return Move.nothing
    }
}
