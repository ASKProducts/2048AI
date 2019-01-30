//
//  WeightsTests.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/28/19.
//

import Foundation

func testWeights() {
    
    let numberOfTrials = 1
    let gamesPerTrial = 10
    let randomRange = 1.0...1.0
    
    var results: [[Double]: [(Double, Double)]] = [:]
    
    let queue = DispatchQueue(label: "weights test queue", attributes: .concurrent)
    let group = DispatchGroup()
    group.enter()
    
    let start = DispatchTime.now()
    
    for i in 1...numberOfTrials {
        
        var weights: [Double] = []
        for _ in 0..<4 {
            let nextWeight = (weights.last ?? 0) + Double.random(in: randomRange)
            weights.append(nextWeight)
        }
        
        print("Starting range #\(i) with weights \(weights)")
        
        for j in 1...gamesPerTrial {
            
            run(in: queue, group: group){
                
                print("Starting game \(j) in range #\(i) with weights \(weights)")
                
                let cache = DictionaryCache()
                let player = ExpectimaxPlayer(maxDepth: 2, samplingAmount: 100, cache: cache)
                let scoreFunc = FastWRCScoreFunction(weights: weights, mergeFactor: 1.0)
                let game = FastGame(startingProbabilities: [2: 1.0], scoreFunc: scoreFunc)
                
                _ = player.playGame(game, printResult: false, printInterval: 0)
                
                print("Ending Game \(j)/\(gamesPerTrial) of weights \(weights).")
                var boardSum = 0.0
                var highestPiece = 0.0
                for r in 0..<4 {
                    for c in 0..<4{
                        boardSum += Double(game.piece(r, c))
                        highestPiece = max(highestPiece, Double(game.piece(r, c)))
                    }
                }
                
                if results[weights] == nil {
                    results[weights] = []
                }
                
                results[weights]?.append((boardSum, highestPiece))
                print("Ending Game Board:")
                print(game)
                print("Board Sum: \(boardSum)")
                print("Total Results:")
                print(results)
                
                print("Total Time Elapsed: \(timeSince(start))")
            }
            
        }
        
    }
    
    group.leave()
    group.notify(queue: queue){
        analyzeWeightsResults(results: results)
        print("Done.")
        exit(EXIT_SUCCESS)
    }
    
    dispatchMain()
}


