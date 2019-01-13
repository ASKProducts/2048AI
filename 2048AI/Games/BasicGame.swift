//
//  BasicGame.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/6/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class BasicGame: Game {
    var board: [[Int]]
    
    
    override init(numRows: Int = 4, numCols: Int = 4, startingProbabilities: [Int: Double], scoreFunc: @escaping ScoreFunc, fillAvailableSpots: Bool = true) {
        board = Array(repeating: Array(repeating: 0, count: numCols), count: numRows)
        super.init(numRows: numRows, numCols: numCols, startingProbabilities: startingProbabilities, scoreFunc: scoreFunc, fillAvailableSpots: fillAvailableSpots)
    }
    
    override func piece(_ r: Int, _ c: Int) -> Int {
        return board[r][c]
    }
    
    override func duplicate() -> Game {
        let newGame = BasicGame(numRows: numRows, numCols: numCols, startingProbabilities: startingProbabilities, scoreFunc: scoreFunc, fillAvailableSpots: false)
        
        for r in 0..<numRows{
            for c in 0..<numCols{
                newGame.board[r][c] = board[r][c]
                if board[r][c] == 0 { newGame.availableSpots.append(Spot(r, c)) }
            }
        }
        
        return newGame
    }
    
    override func addNewPiece(_ piece: Int, at spot: Spot) -> Bool{
        if board[spot.r][spot.c] != 0 { return false }
        board[spot.r][spot.c] = piece
        if let i = availableSpots.firstIndex(where: {$0 == spot}) {
            availableSpots.remove(at: i)
        }
        return true
    }
    
    
    override func makeMove(_ move: Move) -> Bool{
        if !canMove(move) { return false }
        
        availableSpots = []
        for r in 0..<numRows{
            for c in 0..<numCols{
                // a point (r,c) is the "origin" of a line of motion if (r+dr, c+dc) is out of bounds
                if !isInBounds(Spot(r+move.dr, c+move.dc)){
                    //first, extract the line, excluding any 0s, starting at (r,c)
                    var line: [Int] = []
                    var i = 0
                    var spot = Spot(r, c)
                    while isInBounds(spot) {
                        if board[spot.r][spot.c] != 0 {
                            line.append(board[spot.r][spot.c])
                        }
                        i += 1
                        spot = Spot(r-i*move.dr, c-i*move.dc)
                    }
                    
                    
                    //next, compress the line
                    
                    var compressedLine: [Int] = []
                    i = 0
                    while i < line.count {
                        if i < line.count - 1{
                            if line[i] != line[i+1]{
                                compressedLine.append(line[i])
                                i += 1
                            }
                            else{
                                compressedLine.append(2*line[i])
                                i += 2
                            }
                        }
                        else{
                            compressedLine.append(line[i])
                            i += 1
                        }
                        
                    }
                    
                    //finally, reinsert the line into the board
                    
                    i = 0
                    spot = Spot(r, c)
                    while isInBounds(spot) {
                        if i < compressedLine.count {
                            board[spot.r][spot.c] = compressedLine[i]
                        }
                        else {
                            board[spot.r][spot.c] = 0
                            availableSpots.append(spot)
                        }
                        i += 1
                        spot = Spot(r-i*move.dr, c-i*move.dc)
                    }
                }
            }
        }
        return true
    }
    
}
