//
//  Game.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/1/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

typealias ScoreFunc = (Game) -> Double

struct Move: Equatable {
    let dr: Int
    let dc: Int
    
    init(_ dr: Int, _ dc: Int) {
        self.dr = dr
        self.dc = dc
    }
    
    static let left = Move(0, -1)
    static let right = Move(0, 1)
    static let up = Move(-1, 0)
    static let down = Move(1, 0)
    static let mainMoves = [Move.left, Move.down, Move.right, Move.up]
    static let nothing = Move(0, 0)
}


struct Spot: Equatable {
    let r: Int
    let c: Int
    
    init(_ r: Int, _ c: Int) {
        self.r = r
        self.c = c
    }
}

func randomlySample(probabilities: [Int: Double]) -> Int{
    let r = Double.random(in: 0.0 ... 1.0)
    var sumSoFar = 0.0
    for (value, probability) in probabilities {
        if sumSoFar <= r && r <= sumSoFar + probability {
            return value
        }
        sumSoFar += probability
    }
    return -1
}

class Game: CustomStringConvertible {
    let numRows: Int
    let numCols: Int
    var turnNumber = 0
    
    var availableSpots: [Spot]
    let startingProbabilities: [Int: Double]
    let scoreFunc: ScoreFunc
    
    init(numRows: Int = 4, numCols: Int = 4, startingProbabilities: [Int: Double], scoreFunc: @escaping ScoreFunc, fillAvailableSpots: Bool = true) {
        self.numRows = numRows
        self.numCols = numCols
        self.startingProbabilities = startingProbabilities
        self.scoreFunc = scoreFunc
        availableSpots = []
        if fillAvailableSpots {
            for r in 0..<numRows{
                for c in 0..<numCols{
                    availableSpots.append(Spot(r, c))
                }
            }
        }
    }
    
    func piece(at spot: Spot) -> Int {
        return piece(spot.r, spot.c)
    }
    
    func piece(_ r: Int, _ c: Int) -> Int {
        fatalError("Subclass must override piece(::)")
    }
    
    //separate functions provided for hashing and equality so that subclasses can override them
    func computeHash(into hasher: inout Hasher) {
        for r in 0..<numRows {
            for c in 0..<numCols {
                hasher.combine(piece(r, c))
            }
        }
    }
    
    func isEqual(to other: Game) -> Bool{
        if self.availableSpots.count != other.availableSpots.count { return false }
        if (self.numRows, self.numCols) != (other.numRows, other.numCols) { return false }
        for r in 0..<self.numRows {
            for c in 0..<self.numCols {
                if self.piece(r, c) != other.piece(r, c) { return false }
            }
        }
        return true
    }
    
    
    var score: Double {
        return self.scoreFunc(self)
    }
    
    func duplicate() -> Game {
        fatalError("Subclass must override duplicate()")
    }
    
    //print(game) should print the turn, the board, and the score
    var description: String {
        var str = "Turn \(turnNumber):\n"
        for r in 0..<numRows{
            for c in 0..<numCols{
                str += String(format: "%6d ", piece(r, c))
            }
            str += "\n"
        }
        str += "Score: \(score)"
        return str
    }
    
    func isInBounds(_ spot: Spot) -> Bool{
        return 0 <= spot.r && spot.r < numRows &&
            0 <= spot.c && spot.c < numCols
    }
    
    //subclasses can choose to override this function, but its current version should always work
    func canMove(_ move: Move) -> Bool{
        if move == Move.nothing {return false}
        for r in 0..<numRows {
            for c in 0..<numCols {
                if isInBounds(Spot(r+move.dr, c+move.dc)) {
                    if (piece(r, c) != 0 && piece(r+move.dr, c+move.dc) == 0) ||
                        (piece(r, c) != 0 && piece(r, c) == piece(r+move.dr, c+move.dc)) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isGameOver() -> Bool {
        if availableSpots.count > 0 { return false }
        for move in Move.mainMoves {
            if canMove(move) { return false }
        }
        return true
    }
    
    
    //returns whether or not the piece was able to be added. Rememeber to update availableSpots
    func addNewPiece(_ piece: Int, at spot: Spot) -> Bool{
        fatalError("Subclass must override addNewPiece(:at:)")
    }
    
    func addNewRandomPiece() -> Bool {
        if availableSpots.count == 0 { return false }
        
        let r = Int.random(in: 0..<availableSpots.count)
        let spot = availableSpots[r]
        if startingProbabilities.count > 1{
            _ = addNewPiece(randomlySample(probabilities: startingProbabilities), at: spot)
        }
        else{
            guard startingProbabilities.count == 1 else {
                fatalError("startingProbabilities is empty")
            }
            _ = addNewPiece(startingProbabilities.first!.key, at: spot)
        }
        return true
    }
    
    //returns whether or not the move was made. must update availableSpots.
    func makeMove(_ move: Move) -> Bool{
        fatalError("Subclass must override makeMove(:)")
    }
    
}


extension Game: Hashable {
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.isEqual(to: rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        self.computeHash(into: &hasher)
    }
    
}
