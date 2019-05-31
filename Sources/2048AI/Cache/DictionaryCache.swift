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
    let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    
    func initialize(player: ExpectimaxPlayer, game: Game) {
        self.player = player
    }
    
    func getScore(game: Game, depthRemaining: Int) -> Double? {
        semaphore.wait()
        let res = cache[DictionaryCacheEntry(game: game, depthRemaining: depthRemaining)]
        semaphore.signal()
        return res
    }
    
    func storeResult(game: Game, depthRemaining: Int, score: Double) {
        semaphore.wait()
        cache[DictionaryCacheEntry(game: game, depthRemaining: depthRemaining)] = score
        semaphore.signal()
    }
    
    func updateCache(game: Game) {
        
        semaphore.wait()
        var toRemoveKeys: [DictionaryCacheEntry] = []
        guard let player = self.player else {
            fatalError("player was never initialized")
        }
        
        for (key, _) in cache {
            if key.game.turnNumber < game.turnNumber - player.maxDepth {
                toRemoveKeys.append(key)
            }
        }
        for key in toRemoveKeys {
            cache.removeValue(forKey: key)
        }
        
        semaphore.signal()
    }
    
    func endGame() {
        //nothing to close
    }
    
}

