//
//  MergeFactorTests.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/25/19.
//

import Foundation


func testMergeFactors(parallel: Bool){

    let weights: [[Double]] = [[2, 3, 4, 5],
                               [3, 4, 5, 6],
                               [4, 5, 6, 7],
                               [5, 6, 7, 8]]
    
    let mergeFactors = (0...8).map{0.25 * Double($0)}
    let numberOfRuns = 10
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
                let player = ExpectimaxPlayer(maxDepth: 2, samplingAmount: 100, cache: cache)
                let game = FastGame(startingProbabilities: [2: 1],
                                    scoreFunc: FastWMScoreFunction(weights: weights, mergeFactor: mergeFactor))
                _ = player.playGame(game, printResult: false, printInterval: 0)
                
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
