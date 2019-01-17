//
//  DeepCache.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//DeepCache requires the game to be a fastGame for efficient storage representation, and requires the player to be an ExpectimaxPlayer. When using the DeepCache, SamplingAmount must always be 100% so that results are completely deterministic.

class DeepCache {
    
    let game: Game
    
    init(game: Game) {
        self.game = game
    }
    
    func getFileName() -> String {
        var fileName = "CACHE"
        fileName += game.getSignature()
        fileName += game.scoreFunc.getSignature()
        return fileName + ".cache"
    }
    
}
