//
//  ScoreFunctionTests.swift
//  2048AI
//
//  Created by Aaron Kaufer on 2/7/19.
//

import Foundation

struct TesterResult : CustomStringConvertible {
    let scoreFunctionIndex: Int
    let scoreFunction: ScoreFunction
    let trialNumber: Int
    let highestPieceAchieved: Int
    let finalScore: Double
    let finalTurnNumber: Int
    let boardSum: Double
    
    var description: String {
        return "(SF#: \(scoreFunctionIndex), Highest Piece: \(highestPieceAchieved))"
    }
}

class ScoreFunctionTester{
    
    var scoreFunctions: [ScoreFunction]
    
    var chooser: ParameterChoosingFunction
    
    var gamesPerTrial: Int
    var testInParallel: Bool
    
    var useParallelInGames: Bool
    
    var startingProbabilities: [Int: Double]
    var replicateStartingProbabilties: Bool
    
    var printInterval: Int
    
    var overallResults: [[TesterResult]] = []

    init(scoreFunctions: [ScoreFunction],
         chooser: @escaping ParameterChoosingFunction,
         gamesPerTrial: Int = 1,
         testInParallel: Bool = false,
         useParallelInGames: Bool = false,
         startingProbabilities: [Int: Double] = [2: 1.0],
         replicateStartingProbabilties: Bool = true,
         printInterval: Int = 1) {
        
        self.scoreFunctions = scoreFunctions
        self.chooser = chooser
        self.gamesPerTrial = gamesPerTrial
        self.testInParallel = testInParallel
        self.startingProbabilities = startingProbabilities
        self.replicateStartingProbabilties = replicateStartingProbabilties
        self.printInterval = printInterval
        self.useParallelInGames = useParallelInGames
    }
    
    func runTests(completion: @escaping () -> ()){
        
        let queue: DispatchQueue? = testInParallel ? DispatchQueue(label: "score function test queue", attributes: .concurrent) : nil
        let group = DispatchGroup()
        group.enter()
        
        let start = DispatchTime.now()
        
        for (i, scoreFunction) in scoreFunctions.enumerated() {
            
            print("Starting Score Function \(i+1)/\(scoreFunctions.count):")
            print(scoreFunction)
            
            overallResults.append([])
            
            for j in 0..<gamesPerTrial {
        
                run(in: queue, group: group){
                    print("Starting game \(j+1)/\(self.gamesPerTrial) in Score Function \(i+1):")
                    print(scoreFunction)
                    
                    let cache = DictionaryCache()
                    let player = DynamicDepthEMPlayer(chooser: self.chooser,
                                                      cache: cache,
                                                      printHitCount: false,
                                                      replicateStartingProbabilities: self.replicateStartingProbabilties,
                                                      parallel: self.useParallelInGames)
                    
                    let game = FastGame(startingProbabilities: self.startingProbabilities, scoreFunc: scoreFunction)
                    
                    let duration = time{
                        player.playGame(game, printResult: false, printInterval: self.printInterval)
                    }
                    
                    print("Ending game \(j+1)/\(self.gamesPerTrial) in Score Function \(i+1):")
                    print("Final Board:")
                    print(game)
                    
                    print("Game Lasted \(duration) Seconds. (\(timeAsString(duration: duration)))")
                    
                    print("Total Time Elapsed: \(timeSince(start))")
                    
                    var highestPiece = 0
                    var boardSum = 0.0
                    for r in 0..<4 {
                        for c in 0..<4 {
                            if game.piece(r, c) > highestPiece {
                                highestPiece = game.piece(r, c)
                            }
                            boardSum += Double(game.piece(r, c))
                        }
                    }
                    
                    let result = TesterResult(scoreFunctionIndex: i+1,
                                              scoreFunction: scoreFunction,
                                              trialNumber: j+1,
                                              highestPieceAchieved: highestPiece,
                                              finalScore: game.score,
                                              finalTurnNumber: game.turnNumber,
                                              boardSum: boardSum)
                    
                    print("Result: \(result)")
                    
                    self.overallResults[i].append(result)
                    print("Results So Far: \(self.overallResults)")
                    
                    self.analyzeResults(self.overallResults)
                    
                }
                
            }
            
        }
        
        group.leave()
        
        if testInParallel{
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
    
    func analyzeResults(_ results: [[TesterResult]]){
        print("Sorted by geometric mean of highest piece:")
        
        let sortedResults = results.compactMap{ arr -> (ScoreFunction, Double)? in
            guard arr.count != 0 else{ return nil }
            let gm: Double = geometricMean(arr.map{ Double($0.highestPieceAchieved) })
            return (arr[0].scoreFunction, gm)
            }.sorted { $0.1 < $1.1 }
        sortedResults.forEach{ print($0) }
    }
}
