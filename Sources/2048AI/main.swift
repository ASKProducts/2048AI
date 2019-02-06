//
//  main.swift
//  2048AI
//
//  Created by Aaron Kaufer on 12/30/18.
//  Copyright © 2018 Aaron Kaufer. All rights reserved.
//

import Foundation


let bestWeights = [0.4734564083507181, 1.2951105326575059, 1.8412190231058896, 2.7855576423447417]

var weights = generateRandomLightWeights(amount: 30, range: 0.0...1.0, increasing: true)
weights.append([1,2,3,4])

func chooser(game: Game) -> (Int, Int) {
    let numSpots = game.availableSpots.count
    let samplingAmount = 5
    var maxDepth = 0
    
    switch numSpots {
    case 0...4:
        maxDepth = 4
    case 5...10:
        maxDepth = 2
    case 11...16:
        maxDepth = 2
    default:
        maxDepth = 1
    }
    
    return (maxDepth, samplingAmount)
}

/*
testLightWeights(weightsArr: [[0.7837296541192433, 1.7716042130053955, 2.278206884723587, 3.1554465426145732]],
                 preprocessEntries: {$0},
                 gamesPerTrial: 10,
                 parallel: false,
                 chooser: chooser,
                 mergeFactor: 1.0,
                 startingProbabilities: [2: 1],
                 replicateStartingProbabilities: true,
                 printInterval: 1,
                 completion: {exit(0)})
*/

testLightWeights(weightsArr: [[1, 2, 3, -5],
                              [0.4734564083507181, 1.2951105326575059, 1.8412190231058896, 2.7855576423447417],
                              [1, 2, 3, 4]],
                 gamesPerTrial: 1,
                 chooser: {_ in (2,16)},
                 mergeFactor: 1.0,
                 startingProbabilities: [2: 1],
                 printInterval: 1,
                 completion: {exit(0)})


/*

let numberOfRuns = 5


var results: [Double] = []

for i in 0..<numberOfRuns {
    print("Running 2048AI. Run \(i+1)/\(numberOfRuns)")
    
    
    //let cache = FileCache(cacheID: "moves100depth3", storageDepthCap: 3, pruneInterval: 1, writeToFile: false, writeInterval: 1)
    let cache = DictionaryCache()
    let player = DynamicDepthEMPlayer(chooser: {_ in (2,100)},
                                      cache: cache)
    let weights: [[Double]] = [[-100, -50, -25,   1],
                               [ -50, -25,   1,  30],
                               [ -25,   1,  40,  60],
                               [   1,  25,  50, 100]]
    let newWeights: [[Double]] = [[2, 3, 4, 5],
                                  [3, 4, 5, 6],
                                  [4, 5, 6, 7],
                                  [5, 6, 7, 8]]
    let snakeWeights: [[Double]] = [[ 1,  2,  3,   4],
                                    [ 8,  7,  6,   5],
                                     [9, 10, 11,  12],
                                    [16, 15, 14, 13]]
    let wrmWeights: [Double] = [0.7263248415724561, 1.4342987247484718, 1.7514102069565314, 2.344402748408044]
    let scoreFunc = FastWeightedScoreFunction(lightWeights: wrmWeights, mergeFactor: 1.0)
    let fastGame = FastGame(startingProbabilities: [2: 1],
                            scoreFunc: scoreFunc)
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


*/
