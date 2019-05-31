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
    
    let precompute: Bool
    var donePrecomputing: Bool = false
    
    init(precompute: Bool = true) {
        self.precompute = precompute
        super.init()
        if precompute{
            DispatchQueue.global().async {
                self.precomputeTables()
                self.donePrecomputing = true
            }
        }
    }
    
    func precomputeTables() {
        rowScoresTable = [[Double]](repeating: [Double](repeating: 0.0, count: 0xFFFF+1), count: 4)
        colScoresTable = [[Double]](repeating: [Double](repeating: 0.0, count: 0xFFFF+1), count: 4)
        
        for row in UInt16(0)...UInt16(0xFFFF) {
            for r in 0..<4 {
                var entries: [Double] = []
                for i in 0..<4 {
                    let exp = (Int(row) >> (4*(3 - i))) & 0xF
                    let entry = exp == 0 ? 0.0 : Double(1 << exp)
                    entries.append(entry)
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
        var score = 0.0
        if precompute && donePrecomputing{
            guard let game = game as? FastGame else {
                fatalError("Attempting to use precomputed tables on a non-FastGame")
            }
            for i in 0..<4{
                score += rowScoresTable[i][Int(game.getRow(i))]
                score += colScoresTable[i][Int(game.getCol(i))]
            }
        }
        else{
            for i in 0..<4{
                score += rowScore(row: i, entries: (0..<4).map{Double(game.piece(i, $0))})
                score += colScore(col: i, entries: (0..<4).map{Double(game.piece($0, i))})
            }
        }
        
        return score
        

    }
}


