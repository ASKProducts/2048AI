//
//  WashingMachinePlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/2/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class WashingMachinePlayer: Player {
    
    var counter = 0
    
    override func decide(game: Game) -> Move {
        let moves = Move.mainMoves
        while !game.canMove(moves[counter % moves.count]) { counter += 1 }
        let move = moves[counter % moves.count]
        counter += 1
        return move
    }
    
}
