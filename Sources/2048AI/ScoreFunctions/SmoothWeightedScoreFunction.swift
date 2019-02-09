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
    
    init(lightWeights: LightWeights, smoothFactor: Double, emptyScore: Double, smoothZeroes: Bool = false) {
        self.smoothZeroes = smoothZeroes
        super.init(preprocessEntries: {$0.val},
                   lightWeights: lightWeights,
                   individualScore: {$0.val == 0 ? emptyScore : 0},
                   pairScore:
            {smoothZeroes || ($0.val != 0 && $1.val != 0) ? smoothFactor*logDist(a: $0.val, b: $1.val) : 0},
                   additionalDescription: "Smooth Factor \(smoothFactor), Empty Score \(emptyScore)")
    }
    
    init(weights: ScoreWeights, smoothFactor: Double, emptyScore: Double, smoothZeroes: Bool = false){
        self.smoothZeroes = smoothZeroes
        super.init(preprocessEntries: {$0.val},
                   weights: weights,
                   individualScore: {$0.val == 0 ? emptyScore : 0},
                   pairScore:
            {smoothZeroes || ($0.val != 0 && $1.val != 0) ? smoothFactor*logDist(a: $0.val, b: $1.val) : 0},
                   additionalDescription: "Smooth Factor \(smoothFactor), Empty Score \(emptyScore)")
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
