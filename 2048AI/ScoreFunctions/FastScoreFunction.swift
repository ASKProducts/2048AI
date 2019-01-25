//
//  FastScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/24/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation


//A fast score function is one that requires the Game object to be a FastGame, and the score itself must be a function of jus tthe rwos and columns; specifically it needs to be of the form:
// score = sum( row_score(i, row[i]) + col_score(i, col[i]), i=1...4 )
//the subclass provides teh row_score and col_score functions, and the FastScoreFunction class will precompute all values beforehand

class FastScoreFunction: ScoreFunction {
    
    var rowScoresTable: [[Double]] = []
    var colScoresTable: [[Double]] = []
    
    override init() {
        super.init()
        precomputeTables()
    }
    
    func precomputeTables() {
        rowScoresTable = [[Double]](repeating: [Double](repeating: 0.0, count: 0xFFFF+1), count: 4)
        colScoresTable = [[Double]](repeating: [Double](repeating: 0.0, count: 0xFFFF+1), count: 4)
        
        for row in UInt16(0)...UInt16(0xFFFF) {
            for r in 0..<4 {
                var entries: [Double] = []
                for i in 0..<4 {
                    let exp = (Int(row) >> (4*(3 - i))) & 0xF
                    entries.append(Double(1 << exp))
                }
                rowScoresTable[r][Int(row)] = rowScore(row: r, entries: entries)
                colScoresTable[r][Int(row)] = colScore(col: r, entries: entries)
            }
        }
    }
    
    func rowScore(row: Int, entries: [Double]) -> Double{
        return 0.0
    }
    
    func colScore(col: Int, entries: [Double]) -> Double{
        return 0.0
    }
    
    override func calculateScore(of game: Game) -> Double {
        guard let game = game as? FastGame else{
            fatalError("FastScoreFunction called with non-FastGame")
        }
        var score = 0.0
        //expanded out for (very) minor speed benefit
        score += rowScoresTable[0][Int(game.getRow(0))]
        score += rowScoresTable[1][Int(game.getRow(1))]
        score += rowScoresTable[2][Int(game.getRow(2))]
        score += rowScoresTable[3][Int(game.getRow(3))]
        
        score += colScoresTable[0][Int(game.getCol(0))]
        score += colScoresTable[1][Int(game.getCol(1))]
        score += colScoresTable[2][Int(game.getCol(2))]
        score += colScoresTable[3][Int(game.getCol(3))]
        
        return score
        

    }
}


