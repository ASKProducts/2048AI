//
//  UserPlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//play that prompts the user for a move
class UserPlayer: Player{
    override func decide(game: Game) -> Move {
        var move = Move.nothing
        while move == Move.nothing{
            print("How would you like to move? (j,k,l,i)")
            let prompt = readLine()
            if prompt == "j" { move = Move.left }
            if prompt == "k" { move = Move.down }
            if prompt == "l" { move = Move.right }
            if prompt == "i" { move = Move.up }
            if !game.canMove(move) { move = Move.nothing }
        }
        return move
    }
}
