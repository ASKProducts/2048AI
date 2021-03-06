//
//  FastGame.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/6/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class FastGame: Game {
    
    var board: UInt64 = 0
    
    init(startingProbabilities: [Int: Double], scoreFunc: ScoreFunction, fillAvailableSpots: Bool = true) {
        if !FastGame.hasPrecomputedTables {
            FastGame.precomputeTables()
        }
        super.init(numRows: 4, numCols: 4, startingProbabilities: startingProbabilities, scoreFunc: scoreFunc, fillAvailableSpots: fillAvailableSpots)
    }
    
    override func computeHash(into hasher: inout Hasher) {
        hasher.combine(board)
    }
    
    override func isEqual(to other: Game) -> Bool {
        guard let otherFast = other as? FastGame else {
            fatalError("FastGame.isEqual(to:) called with non-FastGame argument")
        }
        return self.board == otherFast.board
    }
    
    func getRow(_ r: Int) -> UInt16 {
        let mask: UInt64 = 0xFFFF000000000000 >> (r*4*4)
        let endShift: Int64 = Int64((3 - r)*4*4)
        return UInt16( ( board & mask ) >> endShift )
    }
    
    func getCol(_ c: Int) -> UInt16 {
        let shiftedBoard: UInt64 = board >> UInt64(4*(3 - c))
        //convert 0xXXXaXXXbXXXcXXXd to 0xabcd
        var col: UInt64 = 0
        col |= shiftedBoard & 0x000000000000000F
        col |= (shiftedBoard & 0x00000000000F0000) >> (4*3)
        col |= (shiftedBoard & 0x0000000F00000000) >> (4*6)
        col |= (shiftedBoard & 0x000F000000000000) >> (4*9)
        return UInt16(col)
    }
    
    static func boardSum(_ board: UInt64) -> Int {
        var mutableBoard = board
        var sum = 0
        for _ in 0..<64 {
            let entry = mutableBoard & 0xF
            if entry != 0 {
                sum += Int(1 << entry)
            }
            mutableBoard >>= 4
        }
        return sum
    }
    
    func pieceExponent(_ r: Int, _ c: Int) -> Int {
        let row = Int(getRow(r))
        return (row >> (4*(3 - c))) & 0xF
    }
    
    override func piece(_ r: Int, _ c: Int) -> Int {
        let exponent = pieceExponent(r, c)
        return exponent == 0 ? 0 : (1 << exponent)
    }
    
    static func reverseRow(_ row: UInt16) -> UInt16 {
        var reversed: UInt16 = 0
        reversed |= (row >> 12)
        reversed |= ((row >> 4) & 0x00F0)
        reversed |= ((row << 4) & 0x0F00)
        reversed |= (row << 12)
        return reversed
    }
    
    static func buildBoardFromRows(_ row1: UInt16, _ row2: UInt16, _ row3: UInt16, _ row4: UInt16) -> UInt64 {
        var board: UInt64 = 0
        board |= UInt64(row1) << (4*4*3)
        board |= UInt64(row2) << (4*4*2)
        board |= UInt64(row3) << (4*4*1)
        board |= UInt64(row4) << (4*4*0)
        return board
    }
    
    //copied from https://github.com/nneonneo/2048-ai/blob/master/2048.cpp
    static func transposeBoard(_ board: UInt64) -> UInt64 {
        let a1 = board & 0xF0F00F0FF0F00F0F;
        let a2 = board & 0x0000F0F00000F0F0;
        let a3 = board & 0x0F0F00000F0F0000;
        let a = a1 | (a2 << 12) | (a3 >> 12);
        let b1 = a & 0xFF00FF0000FF00FF;
        let b2 = a & 0x00FF00FF00000000;
        let b3 = a & 0x00000000FF00FF00;
        return b1 | (b2 >> 24) | (b3 << 24);
    }
    
    static func buildBoardFromCols(_ col1: UInt16, _ col2: UInt16, _ col3: UInt16, _ col4: UInt16) -> UInt64 {
        let preTransposedBoard = buildBoardFromRows(col1, col2, col3, col4)
        return transposeBoard(preTransposedBoard)
    }
    
    
    
    static var shiftRowRightTable: [UInt16] = []
    static var shiftRowLeftTable: [UInt16] = []
    static var shiftColUpTable: [UInt16] = []
    static var shiftColDownTable: [UInt16] = []
    
    static var hasPrecomputedTables = false
    
    static let precomputedTablesFilename = "tables.precomputed"
    
    static func precomputeTables(){
        
        precomputeTablesOnMachine()
        hasPrecomputedTables = true
        
    }
    
    
    static func readTablesFromFile(){
        
        guard let contents = try? String(contentsOfFile: precomputedTablesFilename) else{
            precomputeTablesOnMachine()
            storeTablesInFile()
            return
        }
        
        for (i, numStr) in contents.split(separator: " ").enumerated(){
            guard let num = UInt16(numStr) else { continue }
            switch i{
            case 0...0xFFFF:
                shiftRowRightTable.append(num)
            case 0xFFFF+1...2*0xFFFF+1:
                shiftRowLeftTable.append(num)
            case 2*0xFFFF+2...3*0xFFFF+3:
                shiftColUpTable.append(num)
            case 3*0xFFFF+4...4*0xFFFF+4:
                shiftColDownTable.append(num)
            default: break
            }
        }
        
    }
    
    static func precomputeTablesOnMachine(){
        
        
        shiftRowRightTable = [UInt16](repeating: 0, count: 0xFFFF+1)
        shiftRowLeftTable = [UInt16](repeating: 0, count: 0xFFFF+1)
        shiftColUpTable = [UInt16](repeating: 0, count: 0xFFFF+1)
        shiftColDownTable = [UInt16](repeating: 0, count: 0xFFFF+1)
       
        for row in UInt16(0)...UInt16(0xFFFF) {
            //will make the move to the left, and fill every other entry out accordingly
            
            //first, extract nonzero entries
            var entries: [Int] = []
            for i in 0..<4 {
                let entry = (Int(row) >> (4*(3 - i))) & 0xF
                if entry != 0{ entries.append(entry) }
            }
            
            //compress nonzero entries
            var compressedEntries: [Int] = []
            var i = 0
            while compressedEntries.count < 4 {
                if i < entries.count{
                    if i+1 < entries.count {
                        if entries[i] == entries[i+1] {
                            let newEntry = entries[i] < 15 ? entries[i] + 1 : 15
                            compressedEntries.append(newEntry)
                            i += 2
                        }
                        else{
                            compressedEntries.append(entries[i])
                            i += 1
                        }
                    }
                    else{
                        compressedEntries.append(entries[i])
                        i += 1
                    }
                }
                else{
                    compressedEntries.append(0)
                    i += 1
                }
            }
            
            //turn the new entries into a row
            var shiftedRow: UInt16 = 0
            shiftedRow |= UInt16(compressedEntries[0] << (4*3))
            shiftedRow |= UInt16(compressedEntries[1] << (4*2))
            shiftedRow |= UInt16(compressedEntries[2] << (4*1))
            shiftedRow |= UInt16(compressedEntries[3] << (4*0))
            
            
            shiftRowLeftTable[Int(row)] = shiftedRow
            shiftRowRightTable[Int(reverseRow(row))] = reverseRow(shiftedRow)
            shiftColUpTable[Int(row)] = shiftedRow
            shiftColDownTable[Int(reverseRow(row))] = reverseRow(shiftedRow)
            
        }
        
    }
    
    static func storeTablesInFile(){
        
        var str = ""
        str += shiftRowRightTable.map{"\($0)"}.joined(separator: " ") + " "
        str += shiftRowLeftTable.map{"\($0)"}.joined(separator: " ") + " "
        str += shiftColUpTable.map{"\($0)"}.joined(separator: " ") + " "
        str += shiftColDownTable.map{"\($0)"}.joined(separator: " ")
        let file = FileHandle(forWritingAtPath: precomputedTablesFilename)!
        file.write(str.data(using: .utf8)!)
        
    }
    
    override func duplicate() -> Game {
        let newGame = FastGame(startingProbabilities: startingProbabilities, scoreFunc: scoreFunc, fillAvailableSpots: false)
        newGame.availableSpots.append(contentsOf: availableSpots)
        newGame.board = board
        return newGame
    }
    
    override func canMove(_ move: Move) -> Bool {
        if move == .nothing { return false }
        switch move {
        case .left:
            for r in 0..<numRows {
                let row = getRow(r)
                if row != FastGame.shiftRowLeftTable[Int(row)] { return true }
            }
        case .right:
            for r in 0..<numRows {
                let row = getRow(r)
                if row != FastGame.shiftRowRightTable[Int(row)] { return true }
            }
        case .up:
            for c in 0..<numCols {
                let col = getCol(c)
                if col != FastGame.shiftColUpTable[Int(col)] { return true }
            }
        case .down:
            for c in 0..<numCols {
                let col = getCol(c)
                if col != FastGame.shiftColDownTable[Int(col)] { return true }
            }
            
        default:
            fatalError("canMove(:) was called with an invalid move")
        }
        
        return false
    }
    
    override func addNewPiece(_ piece: Int, at spot: Spot) -> Bool {
        if self.piece(at: spot) != 0 { return false }
        if piece == 0 { return false }
        
        var exp: UInt64 = 0
        while piece != (1 << exp) { exp += 1 }
        
        exp <<= (3 - spot.r)*16
        exp <<= (3 - spot.c)*4
        
        board |= exp
        
        if let i = availableSpots.firstIndex(of: spot) {
            availableSpots.remove(at: i)
        }
        
        return true
    }
    
    func refreshAvailableSpots(){
        availableSpots = []
        for r in 0..<numRows{
            for c in 0..<numCols{
                if pieceExponent(r, c) == 0 {
                    availableSpots.append(Spot(r, c))
                }
            }
        }
    }
    
    override func makeMove(_ move: Move) -> Bool {
        
        if !canMove(move) { return false }
        
        switch move {
        case .nothing:
            return false
        case .left:
            let row1 = FastGame.shiftRowLeftTable[Int(getRow(0))]
            let row2 = FastGame.shiftRowLeftTable[Int(getRow(1))]
            let row3 = FastGame.shiftRowLeftTable[Int(getRow(2))]
            let row4 = FastGame.shiftRowLeftTable[Int(getRow(3))]
            board = FastGame.buildBoardFromRows(row1, row2, row3, row4)
        case .right:
            let row1 = FastGame.shiftRowRightTable[Int(getRow(0))]
            let row2 = FastGame.shiftRowRightTable[Int(getRow(1))]
            let row3 = FastGame.shiftRowRightTable[Int(getRow(2))]
            let row4 = FastGame.shiftRowRightTable[Int(getRow(3))]
            board = FastGame.buildBoardFromRows(row1, row2, row3, row4)
        case .up:
            let col1 = FastGame.shiftColUpTable[Int(getCol(0))]
            let col2 = FastGame.shiftColUpTable[Int(getCol(1))]
            let col3 = FastGame.shiftColUpTable[Int(getCol(2))]
            let col4 = FastGame.shiftColUpTable[Int(getCol(3))]
            board = FastGame.buildBoardFromCols(col1, col2, col3, col4)
        case .down:
            let col1 = FastGame.shiftColDownTable[Int(getCol(0))]
            let col2 = FastGame.shiftColDownTable[Int(getCol(1))]
            let col3 = FastGame.shiftColDownTable[Int(getCol(2))]
            let col4 = FastGame.shiftColDownTable[Int(getCol(3))]
            board = FastGame.buildBoardFromCols(col1, col2, col3, col4)
        default:
            fatalError("makeMove(:) called with invalid move")
        }
        
        refreshAvailableSpots()
        
        return true
    }
}
