//
//  CompoundScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 2/8/19.
//

import Foundation

/* A CompoundScoreFunction is designed to be one of the most customizable score functions possible. It works in three phases:
 first, it runs every board entry through self.preprocessEntries()
 then, it does a weighted sum of the preprocessed entries via self.weights
 then, it runs self.individualScore() on every entry and sums the results (this is a good time to add a bonus for blank spaces)
 then, it runs self.pairScore() on every adjacent pair of values and sums the results (this is a good time to do merge/smooth bonuses)
 */
class CompoundScoreFunction : FastScoreFunction {
    
    typealias BoardEntry = (val: Double, loc: Spot)
    
    let preprocessEntries: (BoardEntry) -> (Double)
    let weights: ScoreWeights
    
    let individualScore: (BoardEntry) -> (Double)
    let pairScore: (BoardEntry, BoardEntry) -> (Double)
    
    static let defaultWeights: ScoreWeights = ScoreWeights(repeating: [1, 1, 1, 1], count: 4)
    
    let additionalDescription: String
    
    var isLightWeights = false
    
    init(preprocessEntries: @escaping (BoardEntry) -> (Double) = {$0.val},
         weights: ScoreWeights = CompoundScoreFunction.defaultWeights,
         individualScore: @escaping (BoardEntry) -> (Double) = {_ in 0},
         pairScore: @escaping (BoardEntry, BoardEntry) -> (Double) = {_,_ in 0},
         additionalDescription: String = "") {
        self.preprocessEntries = preprocessEntries
        self.weights = weights
        self.individualScore = individualScore
        self.pairScore = pairScore
        self.additionalDescription = additionalDescription
        self.isLightWeights = false
    }
    
    init(preprocessEntries: @escaping (BoardEntry) -> (Double) = {$0.val},
         lightWeights: LightWeights,
         individualScore: @escaping (BoardEntry) -> (Double) = {_ in 0},
         pairScore: @escaping (BoardEntry, BoardEntry) -> (Double) = {_,_ in 0},
         additionalDescription: String = "") {
        self.preprocessEntries = preprocessEntries
        self.weights = convertLightWeights(lightWeights)
        self.individualScore = individualScore
        self.pairScore = pairScore
        self.additionalDescription = additionalDescription
        self.isLightWeights = true
    }
    
    override var description: String {
        var str = "{Compound; "
        if self.isLightWeights{
            str += "Light Weights \(self.weights[0].map{ $0 - self.weights[0][0]/2.0 }), "
        }
        else{
            str += "Weights \(self.weights)"
        }
        if additionalDescription != "" {
            str += ", " + additionalDescription
        }
        
        return str + "}"
    }
    
    
    
    override func rowScore(row: Int, entries: [Double]) -> Double {
        
        let preprocessed = entries.enumerated().map{(i, entry) in preprocessEntries((entry, Spot(row, i)))}
        let weightedSum = zip(preprocessed, weights[row]).map{$0.0*$0.1}.reduce(0, +)
        let individualScores = entries.enumerated().map{(i, entry) in individualScore((entry, Spot(row, i)))}
        let individualSum = individualScores.reduce(0, +)
        var pairScoreSum = 0.0
        for i in 1..<4{
            pairScoreSum += pairScore((entries[i-1], Spot(row, i-1)), (entries[i], Spot(row, i)))
        }
        return weightedSum + individualSum + pairScoreSum
    }
    
    override func colScore(col: Int, entries: [Double]) -> Double {
        var pairScoreSum = 0.0
        for i in 1..<4{
            pairScoreSum += pairScore((entries[i-1], Spot(i-1, col)), (entries[i], Spot(i, col)))
        }
        return pairScoreSum
    }
    
}
