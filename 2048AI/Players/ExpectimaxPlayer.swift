//
//  ExpectimaxPlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation


class ExpectimaxPlayer: Player{
    var maxDepth: Int
    var samplingAmount: Int
    
    var cache: Cache?
    
    init(maxDepth: Int, samplingAmount: Int, cache: Cache? = nil){
        self.maxDepth = maxDepth
        self.samplingAmount = samplingAmount
        self.cache = cache
        super.init()
        
        cache?.initialize(player: self)
    }
    
    override func decide(game: Game) -> Move {
        cache?.updateCache(turnNumber: game.turnNumber)
        return pi(game: game, depth: 0)
    }
    
    
    func pi(game: Game, depth: Int) -> Move {
        
        let moves = Move.mainMoves
        var bestMove = Move.nothing
        var bestScore: Double? = nil
        
        for move in moves{
            if !game.canMove(move) { continue }
            
            let score = V(game: game, move: move, depth: depth)
            if bestScore == nil || score > bestScore! {
                bestScore = score
                bestMove = move
            }
        }
        
        return bestMove
    }
    
    func score(game: Game, depth: Int) -> Double {
        if let scoreCache = cache {
            if let bestScore = scoreCache.getScore(game: game, depthRemaining: maxDepth - depth) {
                return bestScore
            }
        }
        
        if depth == maxDepth || game.isGameOver(){
            return game.score
        }
        
        let moves = Move.mainMoves
        var bestScore: Double? = nil
        
        for move in moves{
            if !game.canMove(move) { continue }
            let score = self.V(game: game, move: move, depth: depth + 1)
            if bestScore == nil || score > bestScore! { //force-unwrapping is okay here
                bestScore = score
            }
        }
        
        guard let score = bestScore else{
            fatalError("bestScore is nil after trasversing all moves")
        }
        
        if let scoreCache = cache {
            scoreCache.storeResult(game: game, depthRemaining: maxDepth - depth, score: score)
        }
        
        return score
        
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
