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
    
    var hits = 0
    var totalHits = 0
    
    var cache: Cache?
    let printHitCount: Bool
    
    let parallel: Bool
    
    let parallelizeFirstMoves = true
    let parallelizeFirstSpots = false
    
    //if replicateStartingProbabilities is true, then the expectimax algorithm will search through all starting probabilities. If false, will only recurse into the most likely
    let replicateStartingProbabilities: Bool
    
    init(maxDepth: Int, samplingAmount: Int, cache: Cache? = nil, printHitCount: Bool = false, replicateStartingProbabilities: Bool = true, parallel: Bool = false){
        self.maxDepth = maxDepth
        self.samplingAmount = samplingAmount
        self.cache = cache
        self.printHitCount = printHitCount
        self.replicateStartingProbabilities = replicateStartingProbabilities
        self.parallel = parallel
        super.init()
        
    }
    
    override func decide(game: Game) -> Move {
        if game.turnNumber % 10 == 0{
            cache?.updateCache(game: game)
        }
        hits = 0
        let choice = pi(game: game, depth: 0)
        if cache != nil && printHitCount {
            print("Hits: \(hits)")
            print("Average hits per turn: \(Double(totalHits)/Double(game.turnNumber))")
        }
        return choice
    }
    
    
    func pi(game: Game, depth: Int) -> Move {
        
        let moves = Move.mainMoves
        var bestMove = Move.nothing
        var bestScore: Double? = nil
        
        if parallel && parallelizeFirstMoves  {
            //do things in parallel
            let waitSem = DispatchSemaphore(value: 0)
            
            let queue: DispatchQueue = DispatchQueue(label: "expectimax test queue", attributes: .concurrent)
            let group = DispatchGroup()
            group.enter()
            
            for move in moves{
                run(in: queue, group: group) {
                    if !game.canMove(move) { return }
                    
                    let score = self.V(game: game, move: move, depth: depth)
                    if bestScore == nil || score > bestScore! {
                        bestScore = score
                        bestMove = move
                    }
                }
            }
            
            group.leave()
            //0.89 at the end of turn 30 vs 1.46
            group.notify(queue: queue) {
                waitSem.signal()
            }
            
            waitSem.wait()
        }
        else{
            
            for move in moves{
                if !game.canMove(move) { continue }
                
                let score = V(game: game, move: move, depth: depth)
                if bestScore == nil || score > bestScore! {
                    bestScore = score
                    bestMove = move
                }
            }
        }
        
        return bestMove
    }
    
    func score(game: Game, depth: Int) -> Double {
        hits += 1
        totalHits += 1
        
        if depth == maxDepth || game.isGameOver(){
            return game.score
        }
        if let scoreCache = cache {
            if let bestScore = scoreCache.getScore(game: game, depthRemaining: maxDepth - depth) {
                return bestScore
            }
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
            hits += 1
            totalHits += 1
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
        
        let startingProbabilities: [Int: Double]
        if replicateStartingProbabilities { startingProbabilities = game.startingProbabilities }
        else{
            let startingPiece = game.startingProbabilities.max{ $0.1 < $1.1 }!
            startingProbabilities = [startingPiece.0: 1.0]
        }
        
        if parallel && depth == 0 && parallelizeFirstSpots {
            let queue: DispatchQueue = DispatchQueue(label: "expectimax test queue", attributes: .concurrent)
            let group = DispatchGroup()
            group.enter()
            
            let waitSem = DispatchSemaphore(value: 0)
            
            for spot in availableSpots {
                run(in: queue, group: group) {
                for (piece, probability) in startingProbabilities {
                    //run(in: queue, group: group) {
                        let gameAfterAddingPiece = newGame.duplicate()
                        _ = gameAfterAddingPiece.addNewPiece(piece, at: spot)
                        value += self.score(game: gameAfterAddingPiece, depth: depth) * probability / Double(availableSpots.count)
                    //}
                }
                }
            }
            
            group.leave()
            //23.91 at the end of turn 10
            group.notify(queue: queue) {
                waitSem.signal()
            }
            
            waitSem.wait()
        }
        else{
            
            for spot in availableSpots {
                for (piece, probability) in startingProbabilities {
                    let gameAfterAddingPiece = newGame.duplicate()
                    _ = gameAfterAddingPiece.addNewPiece(piece, at: spot)
                    value += score(game: gameAfterAddingPiece, depth: depth) * probability / Double(availableSpots.count)
                }
            }
        }
        
        
        
        
        return value
    }
    
    override func playGame(_ game: Game, printResult: Bool, printInterval: Int, moveLimit: Int? = nil) {
        cache?.initialize(player: self, game: game)
        
        super.playGame(game, printResult: printResult, printInterval: printInterval, moveLimit: moveLimit)
        
        cache?.endGame()
        
    }
    
}
