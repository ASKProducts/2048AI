//
//  Player.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class Player {
    
    
    func decide(game: Game) -> Move {
        print("ERROR")
        return Move.nothing
    }
    
    func playGame(_ game: Game, printResult: Bool = false, printInterval: Int = 0, moveLimit: Int? = nil){
        game.turnNumber += 1
        
        let gameStartTime = DispatchTime.now()
        
        _ = game.addNewRandomPiece()
        if printInterval != 0 && game.turnNumber % printInterval == 0  { print(game) }
        
        while !game.isGameOver() {
            
            if let moveLimit = moveLimit{
                if game.turnNumber > moveLimit { break }
            }
            
            let start = DispatchTime.now()
            let move = decide(game: game)
            let end = DispatchTime.now()
            let timeTaken = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)/1_000_000_000
            let totalTimeElapsed = Double(end.uptimeNanoseconds - gameStartTime.uptimeNanoseconds)/1_000_000_000
            
            //if printInterval != 0 && numMoves % printInterval == 0 { print("Move Chosen: \(move)") }
            let attempt = game.makeMove(move)
            if !attempt { print("Player made an invalid move") }
            
            _ = game.addNewRandomPiece()
            if printInterval != 0 && game.turnNumber % printInterval == 0 {
                print(game)
                print("Move took \(timeTaken) seconds. \nTotal Time elapsed: \(totalTimeElapsed) seconds. \nAverage \(totalTimeElapsed/Double(game.turnNumber)) seconds per turn.\n")
            }
            
            game.turnNumber += 1
        }
        
        if printResult{
            print("Final Result:")
            print(game)
        }
    }
    
/* old version of the function. keeping around just in case:
 
    func playGame(numRows: Int, numCols: Int, startingProbabiltiies: [Int: Double], scoreFunc: @escaping ScoreFunc, printResult: Bool = false, printInterval: Int = 0) -> Double {
        let game = Game(numRows: numRows, numCols: numCols, startingProbabilities: startingProbabiltiies)
        game.scoreFunc = scoreFunc
        
        game.turnNumber += 1
        
        _ = game.addNewRandomPiece()
        if printInterval != 0 && game.turnNumber % printInterval == 0  { game.printBoard() }
        
        while !game.isGameOver() {
            let move = decide(game: game)
            //if printInterval != 0 && numMoves % printInterval == 0 { print("Move Chosen: \(move)") }
            let attempt = game.makeMove(move)
            if !attempt { print("Player made an invalid move") }
            
            _ = game.addNewRandomPiece()
            if printInterval != 0 && game.turnNumber % printInterval == 0 {
                print("Turn \(game.turnNumber):")
                game.printBoard()
                print("Score: \(game.getScore() ?? -1)")
            }
            
            game.turnNumber += 1
        }
        
        let finalScore = game.getScore() ?? -1
        if printResult{
            game.printBoard()
            print("Final Score: \(finalScore)")
        }
        
        return finalScore
    }
    */
}
