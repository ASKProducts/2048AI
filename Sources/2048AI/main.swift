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

WeightsFinder(gamesPerTrial: 10,
              weightRange: 0...10,
              emptyScore: 100,
              smoothFactor: 20,
              chooser: {_ in (1, 16)},
              useParallelInGames: true,
              startingProbabilities: [2: 0.9, 1: 0.1],
              replicateStartingProbabilties: false,
              printInterval: 0).run(iterations: 3) {
                exit(0)
}

dispatchMain()

/*

let s = DispatchTime.now()

let weights: ScoreWeights = [[0, 0, 0, 0],
                             [0, 0, 0, 0],
                             [0, 0, 0, 0],
                             [0, 0, 0, 4], ]

let lw = [0.7837296541192433, 1.7716042130053955, 2.278206884723587, 3.1554465426145732]
let sf = SmoothWeightedScoreFunction(precompute: true,
                                     weights: weights,
                                     smoothFactor: 20,
                                     emptyScore: 100,
                                     smoothZeroes: false)

func chooser(game: Game) -> (Int, Int) {
    let numSpots = game.availableSpots.count
    let samplingAmount = 16
    var maxDepth = 0
    
    switch numSpots {
    case 0...4:
        maxDepth = 3
    case 5...8:
        maxDepth = 2
    case 9...16:
        maxDepth = 1
    default:
        maxDepth = 1
    }
    
    return (maxDepth, samplingAmount)
}

ScoreFunctionTester(scoreFunctions: [sf],
                    chooser: {_ in (1,16)},
                    gamesPerTrial: 30,
                    testInParallel: false,
                    useParallelInGames: true, //0.234 at 100
                    startingProbabilities: [2: 0.9, 4: 0.1],
                    replicateStartingProbabilties: false,
                    printInterval: 0).runTests {
                        exit(0)
}

dispatchMain()


*/
