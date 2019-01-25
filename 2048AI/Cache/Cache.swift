//
//  Cache.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/17/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

protocol Cache {
    
    //called at the start of playGame
    func initialize(player: ExpectimaxPlayer, game: Game)
    
    //returns nil if (game, depthRemaining) is not in the cache
    func getScore(game: Game, depthRemaining: Int) -> Double?
    
    func storeResult(game: Game, depthRemaining: Int, score: Double)
    
    //called at the start of every turn to run maintanence on the cache if necessary (e.g. pruning)
    func updateCache(game: Game)
    
    //called at the end of the game
    func endGame()
    
}

