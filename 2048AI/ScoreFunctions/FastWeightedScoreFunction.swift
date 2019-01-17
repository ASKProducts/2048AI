//
//  FastWeightedScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation


//FastWeightedScoreFunction is a score function that works in the same way as WeightedScoreFunction, but requires game to be a FastGame and so can precompute all the desired score values on the rows to make for faster computation
class FastWeightedScoreFunction: ScoreFunction{
    
    let weights: [[Double]]
    
    init(weights: [[Double]]) {
        self.weights = weights
        super.init()
        
        precomputeTables()
    }
    
    var scoresTable: [[Double]] = []
    
    func precomputeTables() {
        scoresTable = [[Double]](repeating: [Double](repeating: 0.0, count: 0xFFFF+1), count: 4)
        
        for row in UInt16(0)...UInt16(0xFFFF) {
            for r in 0..<4 {
                for i in 0..<4 {
                    let entry = (Int(row) >> (4*(3 - i))) & 0xF
                    scoresTable[r][Int(row)] += weights[r][i]*Double(1 << entry)
                }
            }
        }
    }
    
    override func calculateScore(of game: Game) -> Double {
        let fastGame = game as! FastGame
        var score = 0.0
        score += scoresTable[0][Int(fastGame.getRow(0))]
        score += scoresTable[1][Int(fastGame.getRow(1))]
        score += scoresTable[2][Int(fastGame.getRow(2))]
        score += scoresTable[3][Int(fastGame.getRow(3))]
        return score
    }
    
}
