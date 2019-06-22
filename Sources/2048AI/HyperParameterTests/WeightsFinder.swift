//
//  WeightsFinder.swift
//  2048AI
//
//  Created by Aaron Kaufer on 6/21/19.
//

import Foundation

struct WeightsFinder{
    
    let gamesPerTrial: Int
    let positionOrder: [(r: Int,c: Int)] = [(3,3), (2,3), (3,2), (1,3), (2, 2), (3, 1), (0, 3), (1, 2), (2, 1), (3, 0), (0, 2), (1, 1), (2, 0), (1,0), (0, 1), (0, 0)]
    
    let initialWeights: ScoreWeights
    
    let weightRange: ClosedRange<Int>
    
    let emptyScore: Double
    let smoothFactor: Double
    
    let chooser: ParameterChoosingFunction
    
    let useParallelInGames: Bool
    
    let startingProbabilities: [Int: Double]
    let replicateStartingProbabilties: Bool
    
    let printInterval: Int
    
    
    
    func run(iterations: Int, completion: () -> ()){
        
        var weights = initialWeights
        
        var bestWeights: ScoreWeights? = nil
        var bestGM: Double? = nil
        
        let start = DispatchTime.now()
        
        for _ in 0..<iterations {
            
            for i in 0..<positionOrder.count {
            
                var results: [(weight: Int, gm: Double)] = []
                let pos = positionOrder[i]
                
                print("Starting position \(pos)")
                
                for w in weightRange{
                    
                    let sf = SmoothWeightedScoreFunction(weights: weights,
                                                         smoothFactor: smoothFactor,
                                                         emptyScore: emptyScore)
                    
                    var highestPieces: [Double] = []
                    
                    weights[pos.r][pos.c] = Double(w)
                    
                    for j in 0..<gamesPerTrial{
                        print("Starting game \(j+1)/\(gamesPerTrial) of position \(pos) set to \(w) with weights:")
                        print(weights)
                        
                        let cache = DictionaryCache()
                        let player = DynamicDepthEMPlayer(chooser: chooser,
                                                          cache: cache,
                                                          printHitCount: false,
                                                          replicateStartingProbabilities: replicateStartingProbabilties,
                                                          parallel: useParallelInGames)
                        
                        let game = FastGame(startingProbabilities: startingProbabilities, scoreFunc: sf)
                        
                        let duration = time{
                            player.playGame(game, printResult: false, printInterval: self.printInterval)
                        }
                        
                        print("Ending game \(j+1)/\(self.gamesPerTrial) of position \(pos) set to \(w) with weights:")
                        print(weights)
                        print("Final Board:")
                        print(game)
                        
                        print("Game Lasted \(duration) Seconds. (\(timeAsString(duration: duration)))")
                        
                        print("Total Time Elapsed: \(timeSince(start))")
                        
                        var highestPiece = 0
                        for r in 0..<4 {
                            for c in 0..<4 {
                                if game.piece(r, c) > highestPiece {
                                    highestPiece = game.piece(r, c)
                                }
                            }
                        }
                        
                        highestPieces.append(Double(highestPiece))
                        print("Highest pieces for weight \(w) in position \(pos) so far: \(highestPieces) (gm of \(geometricMean(highestPieces)))")
                        
                    }
                    
                    let gm = geometricMean(highestPieces)
                    results.append((weight: w, gm: gm))
                    print("Geometric mean for weight \(w) in position \(pos) is \(gm)")
                    
                    print("Results so far for weights in position \(pos): \(results)")
                }
                
                let bestResult = results.max(by: {$0.1 < $1.1})!
                
                print("Best weight for position \(pos) was \(bestResult.weight) with gm \(bestResult.gm)")
                
                weights[pos.r][pos.c] = Double(bestResult.weight)
                if let gm = bestGM {
                    if bestResult.gm > gm{
                        bestWeights = weights
                        bestGM = bestResult.gm
                    }
                }
                else{
                    bestWeights = weights
                    bestGM = bestResult.gm
                }
                
                print("Best weights so far: \(bestWeights!) with gm \(bestGM!)")
            }
            
        }
        
        completion()
        
    }
}
