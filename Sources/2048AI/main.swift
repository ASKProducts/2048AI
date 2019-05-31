//
//  main.swift
//  2048AI
//
//  Created by Aaron Kaufer on 12/30/18.
//  Copyright © 2018 Aaron Kaufer. All rights reserved.
//

import Foundation

/*
let agent = OnlineAgent()
agent.playGame()
*/

let weights: ScoreWeights = [[-1, -1, -1, -1],
                             [-1, -1, -1, -1],
                             [-1, -1,  -1,  1],
                             [-1,  -1,  1,  2], ]
let sf = SmoothWeightedScoreFunction(weights: weights,
                                     smoothFactor: 200,
                                     emptyScore: 1000,
                                     smoothZeroes: false)

func chooser(game: Game) -> (Int, Int) {
    let numSpots = game.availableSpots.count
    let samplingAmount = 5
    var maxDepth = 0
    
    switch numSpots {
    case 0...4:
        maxDepth = 1
    case 5...10:
        maxDepth = 3
    case 11...16:
        maxDepth = 2
    default:
        maxDepth = 1
    }
    
    return (maxDepth, samplingAmount)
}

ScoreFunctionTester(scoreFunctions: [sf],
                    chooser: chooser,
                    gamesPerTrial: 5,
                    testInParallel: false,
                    useParallelInGames: true, //0.234 at 100
                    startingProbabilities: [2: 1, 4:0],
                    replicateStartingProbabilties: false,
                    printInterval: 1).runTests {
                        exit(0)
}

dispatchMain()

