//
//  WeightsTests.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/28/19.
//

import Foundation

func testWeights() {
    
    let numberOfTrials = 100
    let gamesPerTrial = 10
    let randomRange = 0.0...10.0
    
    var results: [[Double]: [Double]] = [:]
    
    let queue = DispatchQueue(label: "merge test queue", attributes: .concurrent)
    let group = DispatchGroup()
    group.enter()
    
    let start = DispatchTime.now()
    
    for i in 1...numberOfTrials {
        
        var weights: [Double] = []
        for _ in 0..<4 {
            weights.append(Double.random(in: randomRange))
        }
        
        print("Starting range #\(i) with weights \(weights)")
        results[weights] = []
        
        for j in 1...gamesPerTrial {
            
            run(in: queue, group: group){
                
                print("Starting game \(j) in range #\(i) with weights \(weights)")
                
                let cache = DictionaryCache()
                let player = ExpectimaxPlayer(maxDepth: 2, samplingAmount: 100, cache: cache)
                let scoreFunc = FastWRCScoreFunction(weights: weights, mergeFactor: 1.0)
                let game = FastGame(startingProbabilities: [2: 1.0], scoreFunc: scoreFunc)
                
                _ = player.playGame(game, printResult: false, printInterval: 0)
                
                print("Ending Game \(j)/\(gamesPerTrial) of weights \(weights).")
                let result = Double(game.turnNumber)*2.0
                results[weights]?.append(result)
                print("Ending Game Board:")
                print(game)
                print("Board Sum: \(result)")
                print("Total Results:")
                print(results)
                
                print("Total Time Elapsed: \(timeSince(start))")
            }
            
        }
        
    }
    
    group.leave()
    
    group.notify(queue: queue){
        exit(EXIT_SUCCESS)
    }
    
    dispatchMain()
}
