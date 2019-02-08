//
//  NneonneoScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 2/7/19.
//

import Foundation


//This is a score function designed to exactly replicate the one used at:
//https://github.com/nneonneo/2048-ai/blob/master/2048.cpp

class NneonneoScoreFunction: FastScoreFunction {
    
    let SCORE_LOST_PENALTY = 200000.0
    let SCORE_MONOTONICITY_POWER = 4.0;
    let SCORE_MONOTONICITY_WEIGHT = 47.0;
    let SCORE_SUM_POWER = 3.5;
    let SCORE_SUM_WEIGHT = 11.0;
    let SCORE_MERGES_WEIGHT = 700.0;
    let SCORE_EMPTY_WEIGHT = 270.0;
    
    override func rowScore(row: Int, entries: [Double]) -> Double {
        let logEntries = entries.map{$0 == 0 ? 0.0 : log2($0)}
        
        var sum = 0.0
        var empty = 0.0
        var merges = 0.0
        var prev = 0
        var counter = 0.0
        
        for i in 0..<4 {
            let entry = Int(logEntries[i])
            sum += pow(Double(entry), SCORE_SUM_POWER)
            if entry == 0 {
                empty += 1
            }
            else{
                if prev == entry {
                    counter += 1
                }
                else if counter > 0{
                    merges += 1 + counter
                    counter = 0
                }
                prev = entry
            }
        }
        if counter > 0 {
            merges += 1 + counter
        }
        
        var monotonicity_left = 0.0
        var monotonicity_right = 0.0
        for i in 1..<4 {
            if logEntries[i-1] > logEntries[i]{
                monotonicity_left += pow(logEntries[i-1], SCORE_MONOTONICITY_POWER) - pow(logEntries[i], SCORE_MONOTONICITY_POWER)
            }
            else{
                monotonicity_right += pow(logEntries[i], SCORE_MONOTONICITY_POWER) - pow(logEntries[i-1], SCORE_MONOTONICITY_POWER)
            }
        }
        
        var score = SCORE_LOST_PENALTY
        score += SCORE_EMPTY_WEIGHT * empty
        score -= SCORE_SUM_WEIGHT * sum
        score -= SCORE_MONOTONICITY_WEIGHT * min(monotonicity_right, monotonicity_left)
        score += SCORE_MERGES_WEIGHT * merges
        return score
    }
    
    override func colScore(col: Int, entries: [Double]) -> Double {
        return rowScore(row:col, entries:entries)
    }
    
    override var description: String {
        return "{nneonneo}"
    }
    
}
