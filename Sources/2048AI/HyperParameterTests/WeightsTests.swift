//
//  WeightsTests.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/28/19.
//

import Foundation


func generateRandomLightWeights(amount: Int, range: ClosedRange<Double>, increasing: Bool = false) -> [LightWeights]{
    var weightsArr: [LightWeights] = []
    for _ in 0..<amount {
        var weights: [Double] = []
        for _ in 0..<4 {
            var nextWeight = Double.random(in: range)
            if increasing { nextWeight += (weights.last ?? 0) }
            weights.append(nextWeight)
        }
        weightsArr.append(weights)
    }
    return weightsArr
}

/*** DEPRECATED IN FAVOR OF ScoreFunctionTests ***/

//note: the user must manually call exit(0) within the completion closure
func testLightWeights(weightsArr: [LightWeights],
                      preprocessEntries: ((Double) -> (Double))? = nil,
                      gamesPerTrial: Int = 10,
                      parallel: Bool = false,
                      chooser: @escaping ParameterChoosingFunction = {_ in (2, 16)},
                      mergeFactor: Double = 1.0,
                      startingProbabilities: [Int: Double] = [2: 1.0],
                      replicateStartingProbabilities: Bool = true,
                      printInterval: Int = 0,
                      completion: @escaping () -> ()) {
    
    var results: [[Double]: [(Double, Double)]] = [:]
    
    let queue: DispatchQueue? = parallel ? DispatchQueue(label: "weights test queue", attributes: .concurrent) : nil
    let group = DispatchGroup()
    group.enter()
    
    let start = DispatchTime.now()
    
    for (i, weights) in weightsArr.enumerated() {
        
        print("Starting range #\(i+1) with weights \(weights)")
        
        for j in 1...gamesPerTrial {
            
            run(in: queue, group: group){
                
                print("Starting game \(j) in range #\(i+1) with weights \(weights)")
                
                let cache = DictionaryCache()
                let player = DynamicDepthEMPlayer(chooser: chooser,
                                                  cache: cache,
                                                  replicateStartingProbabilities: replicateStartingProbabilities)
                let scoreFunc = FastWeightedScoreFunction(lightWeights: weights,
                                                          mergeFactor: mergeFactor,
                                                          preprocessEntries: preprocessEntries)
                let game = FastGame(startingProbabilities: startingProbabilities, scoreFunc: scoreFunc)
                
                player.playGame(game, printResult: false, printInterval: printInterval)
                
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
                
                analyzeWeightsResults(results: results)
                
                print("Total Time Elapsed: \(timeSince(start))")
            }
            
        }
        
    }
    
    group.leave()
    
    if parallel{
        group.notify(queue: queue!){
            print("Done.")
            completion()
        }
    }
    else{
        print("Done.")
        completion()
    }
    
    dispatchMain()
}


