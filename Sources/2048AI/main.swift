//
//  main.swift
//  2048AI
//
//  Created by Aaron Kaufer on 12/30/18.
//  Copyright © 2018 Aaron Kaufer. All rights reserved.
//

import Foundation


let agent = OnlineAgent()
agent.playGame()

dispatchMain()


//DispatchQueue.main.asyncAfter(deadline: .now() + 60){
//    exit(0)
//}

//dispatchMain()

/*
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


let sf = SmoothWeightedScoreFunction(lightWeights: [1, 2, 3, 400], smoothFactor: 1000, emptyScore: 2000, smoothZeroes: false)

//let params = (1...5).map{_ in (Double.random(in: 0...100), Double.random(in: 0...100))}
//let sfs = params.map{ SmoothWeightedScoreFunction(lightWeights: [1, 2, 3, 4], smoothFactor: $0.0, emptyScore: $0.1) }

let tester = ScoreFunctionTester(scoreFunctions: [sf],
                                 chooser: {_ in ( 2,16)},
                                 gamesPerTrial: 10,
                                 parallel: false,
                                 startingProbabilities: [2: 1.0],
                                 replicateStartingProbabilties: true,
                                 printInterval: 1)

tester.runTests{
    exit(0)
}

/*
testLightWeights(weightsArr: [[1, 2, 3, 4]],
                 preprocessEntries: {-pow(log2($0), 3.5)},
                 gamesPerTrial: 2,
                 parallel: false,
                 chooser: {_ in (2, 16)},
                 mergeFactor: 700.0,
                 startingProbabilities: [2: 1],
                 replicateStartingProbabilities: true,
                 printInterval: 1,
                 completion: {exit(0)})
*/


/*
let numberOfRuns = 5


var results: [(Double, Double)] = []

for i in 0..<numberOfRuns {
    print("Running 2048AI. Run \(i+1)/\(numberOfRuns)")
    
    
    //let cache = FileCache(cacheID: "moves100depth3", storageDepthCap: 3, pruneInterval: 1, writeToFile: false, writeInterval: 1)
    let cache = DictionaryCache()
    let player = DynamicDepthEMPlayer(chooser: {_ in (3,16)},
                                      cache: cache)
    let weights: [[Double]] = [[-100, -50, -25,   1],
                               [ -50, -25,   1,  30],
                               [ -25,   1,  40,  60],
                               [   1,  25,  50, 100]]
    let newWeights: [[Double]] = [[0, 0, 2, 2],
                                  [0, 0, 3, 4],
                                  [0, 0, 5, 6],
                                  [0, 0, 7, 8]]
    let snakeWeights: [[Double]] = [[ 1,  2,  3,   4],
                                    [ 8,  7,  6,   5],
                                     [9, 10, 11,  12],
                                    [16, 15, 14, 13]]
    let wrmWeights: [Double] = [0.7263248415724561, 1.4342987247484718, 1.7514102069565314, 2.344402748408044]
    let scoreFunc = NneonneoScoreFunction()
    let fastGame = FastGame(startingProbabilities: [2: 1],
                            scoreFunc: scoreFunc)
    _ = player.playGame(fastGame, printResult: true, printInterval: 1, moveLimit: nil)
    
    var highestTile = 0
    for r in 0..<4{
        for c in 0..<4 {
            let piece = fastGame.piece(r, c)
            if piece > highestTile { highestTile = piece }
        }
    }
    print("Highest piece achieved: \(highestTile)\n\n")
    
    results.append((Double(fastGame.turnNumber), Double(highestTile)))

    print("Results So Far: \(results)")
    //print("Average: \(results.reduce(0.0, +) / Double(results.count))")
}

print("Done.")


*/

 */
