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

func convertLightWeights(_ lightWeights: LightWeights) -> ScoreWeights {
    var weights: ScoreWeights = []
    for r in 0..<4 {
        weights.append([])
        for c in 0..<4 {
            weights[r].append(lightWeights[r] + lightWeights[c])
        }
    }
    return weights
}

class FastWeightedScoreFunction: FastScoreFunction{
    
    let weights: ScoreWeights
    let mergeFactor: Double
    
    var isLightWeights: Bool
    
    var additionalDescription: String?
    
    //this is for if the user wants to square the entries or log them etc. It is only called on the nonzero entries of the board (to allow for log)
    let preprocessEntries: ((Double) -> (Double))?
    
    init(weights: ScoreWeights, mergeFactor: Double = 0.0, preprocessEntries: ((Double) -> (Double))? = nil) {
        self.weights = weights
        self.preprocessEntries = preprocessEntries
        self.mergeFactor = mergeFactor
        self.isLightWeights = false
        super.init()
    }
    
    convenience init(lightWeights: LightWeights, mergeFactor: Double = 0.0, preprocessEntries: ((Double) -> (Double))? = nil) {
        self.init(weights: convertLightWeights(lightWeights),
                  mergeFactor: mergeFactor,
                  preprocessEntries: preprocessEntries)
        self.isLightWeights = true
    }
    
    override var description: String {
        var str = "{Fast Weighted; "
        if self.isLightWeights{
            str += "Light Weights \(self.weights[0].map{ $0 - self.weights[0][0]/2.0 }), "
        }
        else{
            str += "Weights \(self.weights), "
        }
        str += "Merge Factor \(self.mergeFactor)"
        if let additionalDescription = self.additionalDescription {
            str += " " + additionalDescription
        }
        
        return str + "}"
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
        let processedEntries = preprocessEntries == nil ? entries : entries.map{
            return $0 == 0.0 ? 0.0 : preprocessEntries!($0)
        }
        let weightScore = zip(self.weights[row], processedEntries).map{$0.0 * $0.1}.reduce(0.0, +)
        return weightScore + mergeScore(entries: entries)
    }
    
    override func colScore(col: Int, entries: [Double]) -> Double {
        return mergeScore(entries: entries)
    }
    
}
