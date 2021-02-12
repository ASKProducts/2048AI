//
//  AveragedRandomScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 2/11/21.
//

import Foundation

var num = 0
class AveragedRandomScoreFunction: ScoreFunction{
    
    let rounds: Int
    let innerScoreFunction: ScoreFunction
    let moveLimit: Int?
    
    init(rounds: Int, innerScoreFunction: ScoreFunction, moveLimit: Int? = nil) {
        self.rounds = rounds
        self.innerScoreFunction = innerScoreFunction
        self.moveLimit = moveLimit
    }
    
    override func calculateScore(of game: Game) -> Double {
        let randomPlayer = RandomPlayer()
        var scoreSum = 0.0
        for _ in 0..<rounds {
            let newGame = game.duplicate()
            
            num += 1
            randomPlayer.playGame(newGame, moveLimit: self.moveLimit)

            let score = innerScoreFunction.calculateScore(of: newGame)
            scoreSum += score
        }
        return scoreSum / Double(rounds)
        
    }
    
    override var description: String {
        return "{ARSF}"
    }
    
}
