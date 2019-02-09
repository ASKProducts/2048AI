//
//  SmoothWeightedScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 2/8/19.
//

import Foundation

class SmoothWeightedScoreFunction: CompoundScoreFunction {
    
    init(lightWeights: LightWeights, smoothFactor: Double, emptyScore: Double) {
        super.init(preprocessEntries: {$0.val},
                   lightWeights: lightWeights,
                   individualScore: {$0.val == 0 ? emptyScore : 0},
                   pairScore: {smoothFactor/(abs(log2($0.val + 1) - log2($1.val + 1)) + 1)},
                   additionalDescription: "Smooth Factor \(smoothFactor), Empty Score \(emptyScore)")
    }
    
    init(weights: ScoreWeights, smoothFactor: Double, emptyScore: Double){
        super.init(preprocessEntries: {$0.val},
                   weights: weights,
                   individualScore: {$0.val == 0 ? emptyScore : 0},
                   pairScore: {smoothFactor/(abs(log2($0.val + 1) - log2($1.val + 1)) + 1)},
                   additionalDescription: "Smooth Factor \(smoothFactor), Empty Score \(emptyScore)")
    }
    
}
