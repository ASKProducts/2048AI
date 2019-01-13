//
//  ExpectimaxPlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

struct CacheEntry: Hashable {
    let game: Game
    let depth: Int
}

class ExpectimaxPlayer: Player{
    var maxDepth: Int
    var samplingAmount: Int
    
    let useCache: Bool
    var cache: [CacheEntry: Double] = [:]
    
    init(maxDepth: Int, samplingAmount: Int, useCache: Bool = false){
        self.maxDepth = maxDepth
        self.samplingAmount = samplingAmount
        self.useCache = useCache
    }
    
    override func decide(game: Game) -> Move {
        if useCache {
            pruneCache(currentTurnNumber: game.turnNumber)
        }
        return pi(game: game, depth: 0)
    }
    
    func pruneCache(currentTurnNumber: Int){
        var toRemoveKeys: [CacheEntry] = []
        for (key, _) in cache {
            if key.game.turnNumber < currentTurnNumber - maxDepth {
                toRemoveKeys.append(key)
            }
        }
        for key in toRemoveKeys {
            cache.removeValue(forKey: key)
        }
    }
    
    func pi(game: Game, depth: Int) -> Move {
        
        let moves = Move.mainMoves
        var bestMove = Move.nothing
        var bestScore = -1.0
        
        for move in moves{
            if !game.canMove(move) { continue }
            let score = V(game: game, move: move, depth: depth)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        return bestMove
    }
    
    func score(game: Game, depth: Int) -> Double {
        if useCache{
            let entry = CacheEntry(game: game, depth: depth)
            if let bestScore = cache[entry] {
                return bestScore
            }
        }
        
        if depth == maxDepth || game.isGameOver(){
            return game.score
        }
        
        let moves = Move.mainMoves
        var bestScore = -1.0
        
        for move in moves{
            if !game.canMove(move) { continue }
            let score = V(game: game, move: move, depth: depth + 1)
            if score > bestScore {
                bestScore = score
            }
        }
        
        if useCache {
            let entry = CacheEntry(game: game, depth: depth)
            cache.updateValue(bestScore, forKey: entry)
        }
        
        return bestScore
        
    }
    
    func V(game: Game, move: Move, depth: Int) -> Double {
        let newGame = game.duplicate()
        _ = newGame.makeMove(move)
        var availableSpots = newGame.availableSpots
        
        while availableSpots.count > samplingAmount {
            let r = Int.random(in: 0..<availableSpots.count)
            _ = availableSpots.remove(at: r)
        }
        
        var value = 0.0
        
        for spot in availableSpots {
            for (piece, probability) in game.startingProbabilities {
                let gameAfterAddingPiece = newGame.duplicate()
                _ = gameAfterAddingPiece.addNewPiece(piece, at: spot)
                value += score(game: gameAfterAddingPiece, depth: depth) * probability / Double(availableSpots.count)
            }
        }
        
        return value
    }
    
}
