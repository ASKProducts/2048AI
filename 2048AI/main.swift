//
//  main.swift
//  2048AI
//
//  Created by Aaron Kaufer on 12/30/18.
//  Copyright © 2018 Aaron Kaufer. All rights reserved.
//

import Foundation

/*let expectimaxPlayer = ExpectimaxPlayer(maxDepth: 2, samplingAmount: 5)
_ = expectimaxPlayer.playGame(numRows: 4, numCols: 4,
                              startingProbabiltiies: [2: 1],
                              scoreFunc: {100*(blankSpaceScoreFunc(game: $0)+1)+balanceScoreFunc(game: $0)},
                              printResult: true, printInterval: 1)*/

func chooser(game: Game) -> (Int, Int) {
    let numSpots = game.availableSpots.count
    let samplingAmount = 10
    var maxDepth = 0
    
    switch numSpots {
    case 0...4:
        maxDepth = 4
    case 5...10:
        maxDepth = 3
    case 11...16:
        maxDepth = 2
    default:
        maxDepth = 1
    }
    
    return (maxDepth, samplingAmount)
}


let numberOfRuns = 3


for i in 0..<numberOfRuns {
    print("Running 2048AI. Run \(i+1)/\(numberOfRuns)")
    print("Player:")
    print("     DynamicDepthEMPlayer(chooser: {_ in (5, 5)}, useCache: true)")
    print("Game:")
    print("     FastGame(startingProbabilities: [2: 1.0], scoreFunc: fastBalanceScoreFunc)")
    
    
    let player = DynamicDepthEMPlayer(chooser: {_ in (5, 5)}, useCache: true)
    let fastGame = FastGame(startingProbabilities: [2: 1.0],
                            scoreFunc: fastBalanceScoreFunc)
    let basicGame = BasicGame(numRows: 4, numCols: 4, startingProbabilities: [2: 1.0], scoreFunc: balanceScoreFunc)
    _ = player.playGame(fastGame, printResult: true, printInterval: 1)
    var highestTile = 0
    for r in 0..<4{
        for c in 0..<4 {
            let piece = fastGame.piece(r, c)
            if piece > highestTile { highestTile = piece }
        }
    }
    print("Highest piece achieved: \(highestTile)")
    print("Settings:")
    print("Player:")
    print("     DynamicDepthEMPlayer(chooser: {_ in (5, 5)}, useCache: true)")
    print("Game:")
    print("     FastGame(startingProbabilities: [2: 1.0], scoreFunc: fastBalanceScoreFunc)")
    
}

//total weights in original balance function:

/*
 [-15,    -10,    -5,    0],
[ -10,    -5,    0,    5],
[ -5,    0,    5,    10],
[ 0,    5,    10,   15]
 
 
 */
