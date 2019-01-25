//
//  FileCache.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

//DeepCache requires the game to be a FastGame for efficient storage representation, and requires the player to be an ExpectimaxPlayer. When using the DeepCache, if writing is being performed, SamplingAmount must always be 100% so that results are completely deterministic.

//all data will be stored in a file indicated by getFileName(). The file will contain entries of the form:
//<board> <depthRemaining> <score>
//and will be sorted by the sum of the elements on the board. This is because the user will never need to know about turns whose sum lies outside the range [currentSum, currentSum + maxPieceValue*maxDepth]. Thus, every self.pruneInterval turns, the cache will be pruned to remove entries whose sum is less than the current sum. Additionally every turn, any new entries necessary are pulled in from the cache file into the internal cache. This will be accomplished using a StreamReader to read the file one line at a time and stop when the board sum is out of the necessary range. Every time the cache is pruned, the pruned entries (except those with depthRemaining > storageDepthCap) are added to a temporary array of entries to be written to the file cache. Every self.writeInterval turns, the entries of the temporary array are written to the temporary cache file at self.tempfilename (in sorted order). Finally, at the end of the game, the remainder of the cache file added to the lines to be written, which is then written to the temporary cache file, and then the entire temporary cache file is moved into the cache file

struct FileCacheEntry: Hashable{
    let board: UInt64
    let depthRemaining: Int
}

struct FileCacheLine: Comparable{
    let cacheEntry: FileCacheEntry
    let score: Double
    
    static func < (lhs: FileCacheLine, rhs: FileCacheLine) -> Bool {
        return FastGame.boardSum(lhs.cacheEntry.board) < FastGame.boardSum(rhs.cacheEntry.board)
    }
}

class FileCache: Cache {
    
    var player: ExpectimaxPlayer? = nil
    var filename: String? = nil
    var tempfilename: String {
        return "TMP" + filename!
    }
    var cache: [FileCacheEntry: Double] = [:]
    
    let writeInterval: Int
    let pruneInterval: Int
    
    var maxPiece: Int = 0
    var maxDepth: Int = 0
    
    let writeToFile: Bool
    
    var fileReader: StreamReader? = nil
    var tempfile: FileHandle? = nil
    
    //cache entries with depthRemaining > storageDepthCap won't be written to the cachefile
    let storageDepthCap: Int
    var linesToWrite: [FileCacheLine] = []
    
    //can store multiple caches with the same settings by giving different cacheIDs
    var cacheID: String
    
    init(cacheID: String = "", storageDepthCap: Int = 3, pruneInterval: Int = 5, writeToFile: Bool = true, writeInterval: Int = 100) {
        self.cacheID = cacheID
        self.storageDepthCap = storageDepthCap
        self.pruneInterval = pruneInterval
        self.writeInterval = writeInterval
        self.writeToFile = writeToFile
    }
    
    func getFileName(game: Game) -> String {
        var fileName = self.cacheID + "CACHE"
        fileName += game.getSignature()
        fileName += (game.scoreFunc as! Signable).getSignature()
        return fileName + ".cache"
    }
    
    func initialize(player: ExpectimaxPlayer, game: Game) {
        self.filename = getFileName(game: game)
        self.player = player
        
        self.maxPiece = game.startingProbabilities.keys.max()!
        if let player = player as? DynamicDepthEMPlayer {
            //the idea here is that the maximum depth will most likely always occur when there are no spots available, so by passing in a game with no available spots, we can extract the max depth
            let dummyGame = Game(numRows: 4, numCols: 4, startingProbabilities: [2: 1], scoreFunc: ScoreFunction(), fillAvailableSpots: false)
            self.maxDepth = player.chooser(dummyGame).maxDepth
        }
        else{
            self.maxDepth = player.maxDepth
        }
        
        initializeFiles()
        
    }
    
    func initializeFiles(){
        guard let filename = filename else { fatalError("filename never set") }
        
        do {
            let currentDirectory = try FileManager.default.contentsOfDirectory(atPath: ".")
            if !currentDirectory.contains(filename){
                _ = FileManager.default.createFile(atPath: filename, contents: nil, attributes: nil)
            }
            //force-unwrapping so that error comes as early as possible
            self.fileReader = StreamReader(url: URL(fileURLWithPath: filename))!
            
            if !currentDirectory.contains(tempfilename){
                _ = FileManager.default.createFile(atPath: tempfilename, contents: nil, attributes: nil)
            }
            try "".write(toFile: tempfilename, atomically: true, encoding: .utf8)
            self.tempfile = FileHandle(forWritingAtPath: tempfilename)!
            //tempfile?.write("".data(using: .utf8)!)
            
        } catch  {
            fatalError("issue with initializing files")
        }
        
    }
    
    func getScore(game: Game, depthRemaining: Int) -> Double? {
        return cache[FileCacheEntry(board: (game as! FastGame).board, depthRemaining: depthRemaining)]
    }
    
    func storeResult(game: Game, depthRemaining: Int, score: Double) {
        cache[FileCacheEntry(board: (game as! FastGame).board, depthRemaining: depthRemaining)] = score
    }
    
    func updateCache(game: Game) {
        guard let game = game as? FastGame else{
            fatalError("game not of type FastGame")
        }
        
        readCacheEntries(boardSum: FastGame.boardSum(game.board))
        if game.turnNumber % self.pruneInterval == 0 {
            pruneCache(boardSum: FastGame.boardSum(game.board))
        }
        if game.turnNumber % self.writeInterval == 0 {
            writeLinesToTemp()
        }
    }
    
    func readCacheEntries(boardSum: Int) {
        
        let start = DispatchTime.now()
        
        var numRead = 0
        while let line = fileReader!.nextLine() {
            if line == "" { break }
            let cacheLine = processCacheLine(line)
            cache[cacheLine.cacheEntry] = cacheLine.score
            numRead += 1
            if FastGame.boardSum(cacheLine.cacheEntry.board) > boardSum + maxDepth*maxPiece {
                break
            }
        }
        
        let end = DispatchTime.now()
        let timeTaken = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)/1_000_000_000
        
        print("Read \(numRead) lines. Took \(String(format: "%.2f", timeTaken)) seconds")
    }
    
    func processCacheLine(_ line: String) -> FileCacheLine{
        let tokens = line.split(separator: " ")
        let board = UInt64(tokens[0])!
        let depthRemaining = Int(tokens[1])!
        let score = Double(tokens[2])!
        return FileCacheLine(cacheEntry: FileCacheEntry(board: board, depthRemaining: depthRemaining), score: score)
    }
    
    func pruneCache(boardSum: Int){
        
        var toRemoveEntries: [FileCacheEntry] = []
        
        for (entry, _) in cache {
            if FastGame.boardSum(entry.board) < boardSum {
                toRemoveEntries.append(entry)
            }
        }
        
        
        for entry in toRemoveEntries {
            if writeToFile && entry.depthRemaining <= storageDepthCap{
                linesToWrite.append(FileCacheLine(cacheEntry: entry, score: cache[entry]!))
            }
            cache.removeValue(forKey: entry)
        }
        
    }
    
    func writeLinesToTemp(){
        guard writeToFile else { return }
        
        guard let tempfile = tempfile else{
            fatalError("tempfile not set")
        }
        
        let start = DispatchTime.now()
        
        linesToWrite.sort()
        for line in linesToWrite {
            let newLine = "\(line.cacheEntry.board) \(line.cacheEntry.depthRemaining) " + String(format: "%.2f\n", line.score)
            tempfile.write(newLine.data(using: .utf8)!)
        }
        let linesWritten = linesToWrite.count
        linesToWrite.removeAll()
        
        let end = DispatchTime.now()
        let timeTaken = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)/1_000_000_000
        
        print("Wrote \(linesWritten) lines. Took \(String(format: "%.2f", timeTaken)) seconds.")
        
        
        
    }
    
    
    func endGame() {
        
        guard writeToFile else { return }
        
        while let line = fileReader!.nextLine() {
            let cacheLine = processCacheLine(line)
            linesToWrite.append(cacheLine)
        }
        
        for (entry, _) in cache {
            if entry.depthRemaining <= storageDepthCap{
                linesToWrite.append(FileCacheLine(cacheEntry: entry, score: cache[entry]!))
            }
        }
        writeLinesToTemp()
        
        
        do {
            try String(contentsOfFile: tempfilename).write(toFile: filename!, atomically: true, encoding: .utf8)
        } catch  {
            fatalError("failed to write to cache file")
        }
        
    
    }
    
    deinit {
        tempfile?.closeFile()
    }
    
}
