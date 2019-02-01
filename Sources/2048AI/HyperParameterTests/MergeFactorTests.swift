//
//  MergeFactorTests.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/25/19.
//

import Foundation


func testMergeFactors(weights: ScoreWeights,
                      mergeFactors: [Double],
                      numberOfRuns: Int = 10,
                      chooser: @escaping ParameterChoosingFunction = {_ in (2,16)},
                      printInterval: Int = 0,
                      parallel: Bool = false){

    var results: [Double: [Double]] = [:]
    let queue = DispatchQueue(label: "merge test queue",
                              attributes: parallel ? .concurrent : .init(rawValue: 0))
    let group = DispatchGroup()
    group.enter()
    
    let start = DispatchTime.now()
    
    for mergeFactor in mergeFactors {
        results[mergeFactor] = []
        
        for i in 0..<numberOfRuns{
            
            print("Starting Game \(i+1)/\(numberOfRuns) of merge factor \(mergeFactor).\n\n")
            
            run(in: queue, group: group){
                let cache = DictionaryCache()
                let player = DynamicDepthEMPlayer(chooser: chooser, cache: cache)
                let game = FastGame(startingProbabilities: [2: 1],
                                    scoreFunc: FastWeightedScoreFunction(weights: weights,
                                                                         mergeFactor: mergeFactor))
                _ = player.playGame(game, printResult: false, printInterval: printInterval)
                
                print("Ending Game \(i+1)/\(numberOfRuns) of merge factor \(mergeFactor).")
                results[mergeFactor]?.append(Double(game.turnNumber))
                print("Results for current merge factor:")
                print(results[mergeFactor]!)
                print("Average so far: \(ave(arr: results[mergeFactor]!))")
                
                print("Total Results:")
                print(results)
                
                let timeTaken = timeSince(start)
                print("Total Time elapsed: \(timeTaken)")
                
                
            }
            
        }
        
    }
    
    group.leave()
    
    group.notify(queue: queue){
        print("Overall Results:")
        print(results)
        
        print("Averages:")
        let averageDictionary = results.mapValues { ave(arr: $0) }
        print(averageDictionary)
        
        let timeTaken = timeSince(start)
        print("Total Time elapsed: \(timeTaken)")
        
        exit(EXIT_SUCCESS)
    }
    dispatchMain()
}
