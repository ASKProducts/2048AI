//
//  FastWeightedScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//LightWeights represents a type of weighting system where there are only four weights, and we have actualWeight[r][c] = lightWeights[r] + lightWeights[c]. The purpose is to decrease the amount of weights neeed to be tuned to allow for easier optimization
typealias LightWeights = [Double]


class FastWeightedScoreFunction: FastScoreFunction{
    
    let weights: ScoreWeights
    let squareEntries: Bool
    let mergeFactor: Double
    
    init(weights: ScoreWeights, mergeFactor: Double = 0.0, squareEntries: Bool = false) {
        self.weights = weights
        self.squareEntries = squareEntries
        self.mergeFactor = mergeFactor
        super.init()
    }
    
    convenience init(lightWeights: LightWeights, mergeFactor: Double = 0.0, squareEntries: Bool = false) {
        self.init(weights: FastWeightedScoreFunction.convertLightWeights(lightWeights),
                  mergeFactor: mergeFactor, squareEntries: squareEntries)
    }
    
    static func convertLightWeights(_ lightWeights: LightWeights) -> ScoreWeights {
        var weights: ScoreWeights = []
        for r in 0..<4 {
            weights.append([])
            for c in 0..<4 {
                weights[r].append(lightWeights[r] + lightWeights[c])
            }
        }
        return weights
    }
    
    func mergeScore(entries: [Double]) -> Double{
        var score = 0.0
        for i in 0..<3 {
            if entries[i] == entries[i+1]{
                score += mergeFactor*entries[i]
            }
        }
        return score
    }
    
    override func rowScore(row: Int, entries: [Double]) -> Double {
        let exponent = squareEntries ? 2.0 : 1.0
        let weightScore = zip(self.weights[row], entries).map{$0.0 * pow($0.1, exponent)}.reduce(0.0, +)

        return weightScore + mergeScore(entries: entries)
        
        //traditional way:
        /*
        var score = 0.0
        for i in 0..<4 {
            score += self.weights[row][i]*entries[i]
        }
        return score*/
        
        //just for fun, here is how to do it without map:
        //return zip(self.weights[row], entries).reduce(0.0){$0 + ($1.0 * $1.1)}
    }
    
    override func colScore(col: Int, entries: [Double]) -> Double {
        return mergeScore(entries: entries)
    }
    
}
