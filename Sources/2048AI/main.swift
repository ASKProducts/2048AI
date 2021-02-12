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

let innerSF = FastPowerScoreFunction(exponent: 2)
//let innerSF = FastWeightedScoreFunction(lightWeights: [1,2,3,4])
let innerSF2 = FastWeightedScoreFunction(lightWeights: [0.1,0.1,0.1,0.1], mergeFactor: 0, preprocessEntries: {$0*$0 + ($0 == 0 ? 1000 : 0)})

let sf = AveragedRandomScoreFunction(rounds: 10, innerScoreFunction: innerSF2, moveLimit: 50)
let player = ExpectimaxPlayer(maxDepth: 1,
                              samplingAmount: 5,
                              cache: DictionaryCache(),
                              printHitCount: false,
                              replicateStartingProbabilities: true,
                              parallel: true)
let game = FastGame(startingProbabilities: [2: 1.0], scoreFunc: sf)

//let t = time {
player.playGame(game, printResult: true, printInterval: 1)
//}
//print(t)


/*
let weights: [ScoreWeights] =
    [convertLightWeights([1,2,3,4]),
     convertLightWeights([0.7837296541192433, 1.7716042130053955, 2.278206884723587, 3.1554465426145732]),
     [[0.0, 0.0, 4.0, 9.0],
      [0.0, 0.0, 2.0, 8.0],
      [0.0, 0.0, 0.0, 2.0],
      [2.0, 2.0, 3.0, 1.0]],
     
     [[0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [5.0, 10.0, 15.0, 20.0]],
     
     [[0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [4.0, 3.0, 2.0, 1.0],
      [5.0, 6.0, 7.0, 8.0]],
     
     [[0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 1.0],
      [0.0, 0.0, 2.0, 10.0],
      [0.0, 3.0, 20.0, 100.0]],
]

let sfs = weights.map{SmoothWeightedScoreFunction(precompute: false,
                                                  weights: $0,
                                                  smoothFactor: 20,
                                                  emptyScore: 100,
                                                  smoothZeroes: false)}


WeightsFinder(gamesPerTrial: 10,
              initialWeights: constantScoreWeights(0),
              weightRange: -1...10,
              emptyScore: 100,
              smoothFactor: 20,
              chooser: {_ in (0, 16)},
              useParallelInGames: false,
              startingProbabilities: [2: 0.9, 4: 0.1],
              replicateStartingProbabilties: false,
              printInterval: 0).run(iterations: 3) {
                exit(0)
}

dispatchMain()




let s = DispatchTime.now()

let weights: ScoreWeights = [[0, 0, 0, 0],
                             [0, 0, 0, 0],
                             [0, 0, 0, 0],
                             [0, 0, 0, 4], ]

let firstroundgoodweights = [[0.0, 0.0, 4.0, 9.0], [0.0, 0.0, 2.0, 8.0], [0.0, 0.0, 0.0, 2.0], [2.0, 2.0, 3.0, 1.0]]
let firstroundgoodweights_aaron = [[0.0, 0.0, 4.0, 9.0], [0.0, 0.0, 2.0, 8.0], [0.0, 0.0, 0.0, 2.0], [0.0, 0.0, 0.0, 0.0]]

let lw = [0.7837296541192433, 1.7716042130053955, 2.278206884723587, 3.1554465426145732]
let sf = SmoothWeightedScoreFunction(precompute: true,
                                     weights: firstroundgoodweights,
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
        maxDepth = 3
    case 9...16:
        maxDepth = 3
    default:
        maxDepth = 1
    }
    
    return (maxDepth, samplingAmount)
}

ScoreFunctionTester(scoreFunctions: [sf],
                    chooser: {_ in (0,16)},
                    gamesPerTrial: 30,
                    testInParallel: false,
                    useParallelInGames: false, //0.234 at 100
                    startingProbabilities: [2: 1],
                    replicateStartingProbabilties: false,
                    printInterval: 0).runTests {
                        exit(0)
}

dispatchMain()



/**
 
 [[0.0, 0.0, 4.0, 9.0],
  [0.0, 0.0, 2.0, 8.0],
  [0.0, 0.0, 0.0, 2.0],
  [2.0, 2.0, 3.0, 1.0]]
 
 
 */
*/
