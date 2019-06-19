//
//  OnlineAgent.swift
//  2048AI
//
//  Created by Aaron Kaufer on 2/28/19.
//

import Foundation

/* Format for specifying input:
 -------------------
 row 1 weights
 row 2 weights
 row 3 weights
 row 4 weights
 emptyScore
 smoothFactor
 probability of 2
 probability of 4
 search depth
 sampling amount
 -------------------
 */

class OnlineAgent {
    
    var emptyScore: Double? = nil
    var smoothFactor: Double? = nil
    var weights: ScoreWeights? = nil
    var depth: Int? = nil
    var samplingAmount: Int? = nil
    var startingProbabilities: [Int: Double]?
    
    
    init() {
        //manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .compress])
        //socket = manager.defaultSocket
        
        readSettings()
    }
   /* 
    func connectToSocket(completion: @escaping () -> ()){
        socket?.on(clientEvent: .connect){data, ack in
            print("POOP!")
            completion()
        }
        socket?.connect()
    }
   */ 
    func simpleSettings(){
        
        weights = [[1, 1,1,1], [2,2,2,2], [3,3,3,3], [4,4,4,4]]
        emptyScore = 10
        smoothFactor = 10
        startingProbabilities = [2: 1]
        depth = 2;
        samplingAmount = 16
    }
    
    func readSettings(){
        
        //very nicely streamlined functional way to read in the weights. I have the more traditional, easier to read version below
        weights = (0..<4).map{_ in readLine()!.components(separatedBy: " ").map{Double($0)!}}
        
        emptyScore = Double(readLine()!)!
        smoothFactor = Double(readLine()!)!
        
        let prob2 = Double(readLine()!)!
        let prob4 = Double(readLine()!)!
        
        if prob4 != 0{
            startingProbabilities = [2: prob2, 4: prob4]
        }
        else{
            startingProbabilities = [2: prob2]
            guard prob2 == 1 else{
                fatalError("Only 2s, but probability is not 1")
            }
        }
        
        depth = Int(readLine()!)!
        samplingAmount = Int(readLine()!)!
        
        
        
        /*
        weights = []
        for _ in 0..<4{
            var row: [Double] = []
            let line = readLine()!
            let nums = line.components(separatedBy: " ")
            for numStr in nums{
                row.append(Double(numStr)!)
            }
            weights!.append(row)
        }*/
        
    }
    
    func playGame(){
        
        let cache = DictionaryCache()
        let player = ExpectimaxPlayer(maxDepth: depth!,
                                      samplingAmount: samplingAmount!,
                                      cache: cache,
                                      replicateStartingProbabilities: false,
                                      parallel: false)
        let scoreFunction = SmoothWeightedScoreFunction(precompute: true,
                                                        weights: weights!,
                                                        smoothFactor: smoothFactor!,
                                                        emptyScore: emptyScore!,
                                                        smoothZeroes: false)


        let game = FastGame(startingProbabilities: startingProbabilities!, scoreFunc: scoreFunction)
        
        cache.initialize(player: player, game: game)
        
        while !game.isGameOver() {
            //print(game)
            switch game.turnNumber % 2{
            case 0:
                addNewTile(game: game)
            case 1:
                makePlayerMove(player: player, game: game)
            default:
                break
            }
            game.turnNumber += 1
            let board: [[Int]] = (0..<4).map{r in (0..<4).map{c in game.piece(r, c)}}
            print("{\"type\": \"state\", \"board\": \"\(board)\"}")
        }
    }
    
    func addNewTile(game: Game){
        if let (piece, spot) = game.addNewRandomPiece(){
            //socket.emit("place", with: [piece, spot.r, spot.c])
            print("{\"type\": \"place\", \"piece\": \(piece), \"row\": \(spot.r), \"col\": \(spot.c)}")
        }
        else{
            //no piece could be added
        }
    }
    
    func makePlayerMove(player: Player, game: Game){
        let move = player.decide(game: game)
        let moveStr: String
        switch move {
        case .left: moveStr = "L"
        case .right: moveStr = "R"
        case .up: moveStr = "U"
        case .down: moveStr = "D"
        default: moveStr = "X"
        }
        
        _ = game.makeMove(move)
        
        //socket.emit("move", with: [moveStr])
        print("{\"type\": \"move\", \"dir\": \"\(moveStr)\"}")
    }
}
