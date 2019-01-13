//
//  FastScoreFunctions.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/7/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

func fastSquareScoreFunc(game: Game) -> Double {
    let fastGame = game as! FastGame
    var score = 0.0
    score += FastGame.squareScoresTable[Int(fastGame.getRow(0))]
    score += FastGame.squareScoresTable[Int(fastGame.getRow(1))]
    score += FastGame.squareScoresTable[Int(fastGame.getRow(2))]
    score += FastGame.squareScoresTable[Int(fastGame.getRow(3))]
    return score
}

func fastBalanceScoreFunc(game: Game) -> Double {
    let fastGame = game as! FastGame
    var score = 0.0
    score += FastGame.balanceScoresTable[0][Int(fastGame.getRow(0))]
    score += FastGame.balanceScoresTable[1][Int(fastGame.getRow(1))]
    score += FastGame.balanceScoresTable[2][Int(fastGame.getRow(2))]
    score += FastGame.balanceScoresTable[3][Int(fastGame.getRow(3))]
    return score
}

func fastComboScoreFunc(game: Game) -> Double {
    return fastBalanceScoreFunc(game: game) + fastSquareScoreFunc(game: game)
}
