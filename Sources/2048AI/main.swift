//
//  main.swift
//  2048AI
//
//  Created by Aaron Kaufer on 12/30/18.
//  Copyright © 2018 Aaron Kaufer. All rights reserved.
//

import Foundation


testMergeFactors()
exit(0)

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


let numberOfRuns = 5


var results: [Double] = []

for i in 0..<numberOfRuns {
    print("Running 2048AI. Run \(i+1)/\(numberOfRuns)")
    
    
    //let cache = FileCache(cacheID: "moves100depth3", storageDepthCap: 3, pruneInterval: 1, writeToFile: false, writeInterval: 1)
    let cache = DictionaryCache()
    let player = DynamicDepthEMPlayer(chooser: {_ in (3, 5)},
                                      cache: cache)
    let weights: [[Double]] = [[-100, -50, -25,   1],
                               [ -50, -25,   1,  30],
                               [ -25,   1,  40,  60],
                               [   1,  25,  50, 100]]
    let newWeights: [[Double]] = [[2, 3, 4, 5],
                                  [3, 4, 5, 6],
                                  [4, 5, 6, 7],
                                  [5, 6, 7, 8]]
    let fastGame = FastGame(startingProbabilities: [2: 1],
                            scoreFunc: FastWMScoreFunction(weights: newWeights, mergeFactor: 1.5))
    _ = player.playGame(fastGame, printResult: true, printInterval: 1, moveLimit: nil)
    results.append(Double(fastGame.turnNumber))
    
    var highestTile = 0
    for r in 0..<4{
        for c in 0..<4 {
            let piece = fastGame.piece(r, c)
            if piece > highestTile { highestTile = piece }
        }
    }
    print("Highest piece achieved: \(highestTile)\n\n")

    print("Results So Far: \(results)")
    print("Average: \(results.reduce(0.0, +) / Double(results.count))")
}

print("Done.")

