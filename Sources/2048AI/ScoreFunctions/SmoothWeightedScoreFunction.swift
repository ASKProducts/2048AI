//
//  SmoothWeightedScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 2/8/19.
//

import Foundation

func logDist(a: Double, b: Double) -> Double {
    return 1.0/(abs(log2(a + 1) - log2(b + 1)) + 1)
}

class SmoothWeightedScoreFunction: CompoundScoreFunction {
    
    let smoothZeroes: Bool
    
    init(precompute: Bool = true, lightWeights: LightWeights, smoothFactor: Double, emptyScore: Double, smoothZeroes: Bool = false) {
        self.smoothZeroes = smoothZeroes
        super.init(precompute: precompute,
                   preprocessEntries: {$0.val},
                   lightWeights: lightWeights,
                   individualScore: {$0.val == 0 ? emptyScore : 0},
                   pairScore:{SmoothWeightedScoreFunction.pairScore(piece1: $0.val, piece2: $1.val,
                                                                    smoothFactor: smoothFactor, smoothZeroes: smoothZeroes)},
                   additionalDescription: "Smooth Factor \(smoothFactor), Empty Score \(emptyScore)")
    }
    
    init(precompute: Bool = true, weights: ScoreWeights, smoothFactor: Double, emptyScore: Double, smoothZeroes: Bool = false){
        self.smoothZeroes = smoothZeroes
        super.init(precompute: precompute,
                   preprocessEntries: {$0.val},
                   weights: weights,
                   individualScore: {$0.val == 0 ? emptyScore : 0},
                   pairScore: {SmoothWeightedScoreFunction.pairScore(piece1: $0.val, piece2: $1.val,
                                                                     smoothFactor: smoothFactor, smoothZeroes: smoothZeroes)},
                   additionalDescription: "Smooth Factor \(smoothFactor), Empty Score \(emptyScore)")
    }
    
    static func pairScore(piece1: Double, piece2: Double, smoothFactor: Double, smoothZeroes: Bool) -> Double{
        if smoothZeroes || (piece1 != 0 && piece2 != 0) {
            //let smallestExp = [piece1, piece2].map{log2($0 + 1)}.min()!
            return smoothFactor * logDist(a: piece1, b: piece2)
        }
        return 0
    }
    
    
    override var description: String {
        if smoothZeroes{
            return super.description + ", Smooth Zeroes"
        }
        else{
            return super.description
        }
    }
    
}
