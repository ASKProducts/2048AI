//
//  DictionaryCache.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/17/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//


//simple Cache implemented as a dictionary
import Foundation

struct DictionaryCacheEntry: Hashable {
    let game: Game
    let depthRemaining: Int
}



class DictionaryCache: Cache {
    
    
    var cache: [DictionaryCacheEntry: Double] = [:]
    var player: ExpectimaxPlayer? = nil
    
    func initialize(player: ExpectimaxPlayer) {
        self.player = player
    }
    
    func getScore(game: Game, depthRemaining: Int) -> Double? {
        return cache[DictionaryCacheEntry(game: game, depthRemaining: depthRemaining)]
    }
    
    func storeResult(game: Game, depthRemaining: Int, score: Double) {
        cache[DictionaryCacheEntry(game: game, depthRemaining: depthRemaining)] = score
    }
    
    func updateCache(turnNumber: Int) {
        var toRemoveKeys: [DictionaryCacheEntry] = []
        guard let player = self.player else {
            fatalError("player was never initialized")
        }
        
        for (key, _) in cache {
            if key.game.turnNumber < turnNumber - player.maxDepth {
                toRemoveKeys.append(key)
            }
        }
        for key in toRemoveKeys {
            cache.removeValue(forKey: key)
        }
    }
    
    
}

